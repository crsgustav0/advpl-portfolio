#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "protheus.ch"

STATIC cPrefDef := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} WSORCITEM

    Carrega os dados dos ITENS DO ORÇAMENTO ou do registro posicionado

@author  leonardo.castro
@since   27/04/2021
/*/
//-------------------------------------------------------------------
WSRESTFUL WSORCITEM DESCRIPTION "EndPoint ORÇAMENTO API" FORMAT "application/json"

	WSDATA Page     AS INTEGER
	WSDATA PageSize AS INTEGER
	WSDATA Token    AS CHARACTER
	WSDATA Order    AS CHARACTER OPTIONAL
	WSDATA Fields   AS CHARACTER OPTIONAL
	WSDATA CompanyId  AS CHARACTER OPTIONAL
	WSDATA BranchId   AS CHARACTER OPTIONAL
	WSDATA CustomerKey AS CHARACTER OPTIONAL
	WSDATA BrowseSearch AS LOGICAL OPTIONAL
	WSDATA WHEREAPIADP AS CHARACTER OPTIONAL

	WSMETHOD GET DESCRIPTION "Retorna uma lista de ITENS DO ORÇAMENTO" WSSYNTAX "/WSORCITEM"

END WSRESTFUL

WSMETHOD GET WSSERVICE WSORCITEM

	Local lRet          As Logical
	Local oOrcItem      As Object
	Local oItems        As Object
	Local oJson         As Object
	Local oLibPyli      As Object
	Local cJson         As Character
	Local cEmail        As Character
	Local cID           As Character
	Local i             As Numeric
	Local lUser         As Logical
	Local aQueryParms   As Array

	Private lVldCst     As Logical

	// API FORMAT
	Self:SetContentType('application/json')

	// Query Params
	DEFAULT Self:CompanyId := ''
	DEFAULT Self:BranchId := ''
	DEFAULT Self:Token := ''
	DEFAULT Self:CustomerKey := ''
	DEFAULT Self:BrowseSearch := .T.
	DEFAULT Self:WHEREAPIADP := ''

	aQueryParms := Array(0)
	For i := 1 To Len(Self:aQueryString)
		If !(Self:aQueryString[i][1] $ 'COMPANYID|BRANCHID|TOKEN|CUSTOMERKEY|BROWSESEARCH|WHEREAPIADP')
			aAdd(aQueryParms,Self:aQueryString[i])
		EndIf
	Next i

	// Preparação do Ambiente PROTHEUS
	oLibPyli:= LibPyli():New()
	oLibPyli:FsEmpFil(Self:CompanyId,Self:BranchId)

	lRet        := .T.
	oJson       := JsonObject():New()
	oItems      := JsonObject():New()
	cJson       := ''
	cEmail      := ''
	cID         := ''
	lUser       := .F.
	Self:CustomerKey := U_FormatId(Self:CustomerKey)
	Self:BrowseSearch := U_FormatL(Self:BrowseSearch)

	//Validação código cliente para filtro de registros
	lVldCst := oLibPyli:FsVldCst(Self:CustomerKey)

	Private cClientKey := Self:CustomerKey

	// Carrega config cTabelas do Portal
	cPrefDef := SuperGetMv("FS_TABWEB",.T.,"PW")

	DbSelectArea(cPrefDef+"0")
	(cPrefDef+"0")->(DbSetOrder(2))

	lUser  := oLibPyli:ValidUser(Self:Token)

	If !lUser
		SetRestFault(400,EncodeUtf8('Invalid Token, validação de usuário incorreta.'))
		Return
	EndIf

	// CliAdapter é nossa CLASSE que fornece os dados dos ITENS DO ORÇAMENTO ao WS
	oOrcItem := APIAdapter():New( 'GET' )

	//Processa os dados dos ITENS DO ORÇAMENTO
	oOrcItem:SetTable('SCK')

	// GET Específico via ID
	If !Empty(Self:aURLParms)
		SCK->(DbSetOrder(1))
		cID := SubStr(U_FormatID(Self:aURLParms[1]),1,Len(cFilAnt)+TamSX3("CK_NUM")[1])
		If Empty(cID) .Or. !SCK->(DbSeek(cID))
			SetRestFault(400,EncodeUtf8('Invalid id, registro informado não encontrado.'))
			Return
		EndIf

		Self:Page := 1
		Self:PageSize := 999
		Self:WHEREAPIADP := ''
		Self:BrowseSearch := .F.
	EndIf

	//Define a Pagina a ser Retornada
	oOrcItem:SetPage(Self:Page)

	//Indica quantidade de registros da pagina
	oOrcItem:SetPageSize(Self:PageSize)

	//Indica a ordem definida por querystring
	//oOrcItem:SetOrderQuery(Self:Order)

	//Indica o filtro querystring recebido (pode se utilizar um filtro oData)
	oOrcItem:SetUrlFilter(aQueryParms)

	//Indica os campos que serão retornados via querystring
	oOrcItem:SetFields(Self:Fields)

	oOrcItem:SetBrowseSearch( Self:BrowseSearch )
	oOrcItem:SetFilter( FilterSCK( Self:CustomerKey, Self:BrowseSearch ), GetFilORC() )
	oOrcItem:SetOrderAPI( OrderSCK( Self:Order ) )
	oOrcItem:WHEREAPIADP := IIF( !Empty(Self:WHEREAPIADP), Self:WHEREAPIADP, '')
	oOrcItem:GetList()

	// Se tudo ocorreu bem, retorna os dados via Json
	If oOrcItem:lOk

		// Indica as informações das PROPRIEDADES
		oOrcItem:GetPropert()

		// Definição das PROPRIEDADES
		oJson['status'] := 'ok'

		If ValType(oOrcItem:oTitle) == "J"
			oJson['titulo'] := oOrcItem:oTitle
		EndIf

		If ValType(oOrcItem:aOrder) == "A"
			oJson['ordem'] := oOrcItem:aOrder
		EndIf

		If ValType(oOrcItem:aApp) == "A"
			oJson['app'] := oOrcItem:aApp
		EndIf

		If ValType(oOrcItem:oTotais) == "J"
			oJson['totalizadores'] := FTotalSCK(oOrcItem)
		EndIf

		If ValType(oOrcItem:oTypeField) == "J"
			oJson['fieldTypeConfig'] := oOrcItem:oTypeField
		EndIf

		If ValType(oOrcItem:oTypeFilter) == "J"
			oJson['filtros'] := oOrcItem:oTypeFilter
		EndIf

		// Tratamentos de ITENS DO ORÇAMENTO para os DADOS
		oItems:FromJson(oOrcItem:cJSON)
		If ValType(oItems) == "J"
			oJson['dados'] := oItems['items']
			oJson['hasNext'] := oItems['hasNext']
			oJson['totalPages'] := oItems['totalPages']
		EndIf

		Self:SetResponse(U_EncodeETX(oJson:toJSON()))

	Else
		// Retorna o erro encontrado durante o processamento.
		SetRestFault(oOrcItem:GetCode(),oOrcItem:GetMessage())
		lRet := .F.
	EndIf

	// Desalocação dos Objetos e Arrays utilizados
	oOrcItem:DeActivate()
	oOrcItem := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FilterSCK
Define filtro padrão para tabela SCK - Itens do ORÇAMENTO

@author  leonardo.castro
@since   23/04/2021
/*/
//-------------------------------------------------------------------
Static Function FilterSCK( cClientKey, lBrowse ) As Character

	Local aArea     As Array
	Local cFiltro   As Character
	Local cEmail    As Character

	DEFAULT cClientKey := ""
	DEFAULT lBrowse := .F.

	aArea   := FwGetArea()
	cFiltro := ''
	cEmail := (cPrefDef+"0")->&(cPrefDef+"0_EMAIL")

	// Busca de BROWSE
	If lBrowse
		// Chave de busca do cliente selecionado no PORTAL.
		If lVldCst
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(cClientKey))

			cFiltro += IIF(!Empty(cFiltro)," AND ","")
			cFiltro += " SCK.CK_CLIENTE = '" + SA1->A1_COD +"' AND SCK.CK_LOJA = '" + SA1->A1_LOJA + "' "
		EndIf
	Else
		// Busca específica do REGISTRO
		cFiltro += " SCK.CK_FILIAL = '"+ SCK->CK_FILIAL +"' AND SCK.CK_NUM = '"+ SCK->CK_NUM +"' "
	EndIf

	FwrestArea(aArea)

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} OrderSCK
Define ordenação padrão para tabela SCK - ITENS DO ORÇAMENTO

@author  leonardo.castro
@since   23/04/2021
/*/
//-------------------------------------------------------------------
Static Function OrderSCK( cOrdParam ) As Character

	Local aArea     As Array
	Local cOrdem    As Character

	DEFAULT cOrdParam := ''

	aArea := FwGetArea()

	If Empty(cOrdParam)
		cOrdem := "CK_FILIAL, CK_NUM, CK_ITEM "
	Else
		cOrdem := cOrdParam
	EndIf

	FwrestArea(aArea)

Return cOrdem

//-------------------------------------------------------------------
/*/{Protheus.doc} FTotalSCK

Define os totalizadores para o serviço SCK - ITENS DO ORÇAMENTO

@author  leonardo.castro
@since   28/04/2021
/*/
//-------------------------------------------------------------------
Static Function FTotalSCK( oOrcItem )

	Local oJson As Object

	DEFAULT oOrcItem := JsonObject():New()

	oJson := JsonObject():New()

	// Totalizador dos Registros
	oJson['totRegistros'] := oOrcItem:oTotais

Return oJson

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilORC

    Retorna lista de filiais dos Pedidos

@author  leonardo.castro
@since   12/05/2021
/*/
//-------------------------------------------------------------------
Static Function GetFilORC()

	Local cFil As Character

	cFil := U_FGetPropert( (cPrefDef+"0")->&(cPrefDef+"0_CODIGO"), "defaultBranchORC" )

	If Empty(cFil)
		cFil := FWxFilial("SCJ")
	EndIf

Return cFil
