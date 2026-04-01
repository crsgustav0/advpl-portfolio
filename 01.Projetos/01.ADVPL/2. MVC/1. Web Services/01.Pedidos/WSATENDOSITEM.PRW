#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "protheus.ch"

STATIC cPrefDef := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} WSATENDOSITEM
Carrega os dados dos ITENS DO ATENDIMENTO ou do registro posicionado

@author  leonardo.castro
@since   27/04/2021
/*/
//-------------------------------------------------------------------
WSRESTFUL WSATENDOSITEM DESCRIPTION "EndPoint ITENS DO ATENDIMENTO API" FORMAT "application/json"

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

	WSMETHOD GET DESCRIPTION "Retorna uma lista de ITENS DO ATENDIMENTO" WSSYNTAX "/WSATENDOSITEM"

END WSRESTFUL

WSMETHOD GET WSSERVICE WSATENDOSITEM

	Local lRet          As Logical
	Local oAOSItem      As Object
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

	Private cFabKey := Self:CustomerKey

	// Carrega config cTabelas do Portal
	cPrefDef := SuperGetMv("FS_TABWEB",.T.,"PW")

	DbSelectArea(cPrefDef+"0")
	(cPrefDef+"0")->(DbSetOrder(2))

	lUser  := oLibPyli:ValidUser(Self:Token)

	If !lUser
		SetRestFault(400,EncodeUtf8('Invalid Token, validação de usuário incorreta.'))
		Return
	EndIf

	// CliAdapter é nossa CLASSE que fornece os dados dos ITENS DO ATENDIMENTO ao WS
	oAOSItem := APIAdapter():New( 'GET' )

	//Processa os dados dos ITENS DO ATENDIMENTO
	oAOSItem:SetTable('ABA')

	// GET Específico via ID
	If !Empty(Self:aURLParms)
		ABA->(DbSetOrder(1))
		cID := U_FormatID(Self:aURLParms[1])
		If Empty(cID) .Or. !ABA->(DbSeek(cID))
			SetRestFault(400,EncodeUtf8('Invalid id, registro informado não encontrado.'))
			Return
		EndIf

		Self:Page := 1
		Self:PageSize := 999
		Self:WHEREAPIADP := ''
		Self:BrowseSearch := .F.
	EndIf

	//Define a Pagina a ser Retornada
	oAOSItem:SetPage(Self:Page)

	//Indica quantidade de registros da pagina
	oAOSItem:SetPageSize(Self:PageSize)

	//Indica a ordem definida por querystring
	//oAOSItem:SetOrderQuery(Self:Order)

	//Indica o filtro querystring recebido (pode se utilizar um filtro oData)
	oAOSItem:SetUrlFilter(aQueryParms)

	//Indica os campos que serão retornados via querystring
	oAOSItem:SetFields(Self:Fields)

	oAOSItem:SetBrowseSearch( Self:BrowseSearch )
	oAOSItem:SetFilter( FilterABA( Self:CustomerKey, Self:BrowseSearch ) )
	oAOSItem:SetOrderAPI( OrderABA( Self:Order ) )
	oAOSItem:WHEREAPIADP := IIF( !Empty(Self:WHEREAPIADP), Self:WHEREAPIADP, '')
	oAOSItem:GetList()

	// Se tudo ocorreu bem, retorna os dados via Json
	If oAOSItem:lOk

		// Indica as informações das PROPRIEDADES
		oAOSItem:GetPropert()

		// Definição das PROPRIEDADES
		oJson['status'] := 'ok'

		If ValType(oAOSItem:oTitle) == "J"
			oJson['titulo'] := oAOSItem:oTitle
		EndIf

		If ValType(oAOSItem:aOrder) == "A"
			oJson['ordem'] := oAOSItem:aOrder
		EndIf

		If ValType(oAOSItem:aApp) == "A"
			oJson['app'] := oAOSItem:aApp
		EndIf

		If ValType(oAOSItem:oTotais) == "J"
			oJson['totalizadores'] := FTotalABA(oAOSItem)
		EndIf

		If ValType(oAOSItem:oTypeField) == "J"
			oJson['fieldTypeConfig'] := oAOSItem:oTypeField
		EndIf

		If ValType(oAOSItem:oTypeFilter) == "J"
			oJson['filtros'] := oAOSItem:oTypeFilter
		EndIf

		// Tratamentos de ITENS DO ATENDIMENTO para os DADOS
		oItems:FromJson(oAOSItem:cJSON)
		If ValType(oItems) == "J"
			oJson['dados'] := oItems['items']
			oJson['hasNext'] := oItems['hasNext']
			oJson['totalPages'] := oItems['totalPages']
		EndIf

		Self:SetResponse(U_EncodeETX(oJson:toJSON()))

	Else
		// Retorna o erro encontrado durante o processamento.
		SetRestFault(oAOSItem:GetCode(),oAOSItem:GetMessage())
		lRet := .F.
	EndIf

	// Desalocação dos Objetos e Arrays utilizados
	oAOSItem:DeActivate()
	oAOSItem := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FilterABA
Define filtro padrão para tabela ABA - Itens do Atendimento OS

@author  leonardo.castro
@since   23/04/2021
/*/
//-------------------------------------------------------------------
Static Function FilterABA( cFabKey, lBrowse ) As Character

	Local aArea     As Array
	Local cFiltro   As Character
	Local cEmail    As Character

	DEFAULT cFabKey := ""
	DEFAULT lBrowse := .F.

	aArea   := FwGetArea()
	cFiltro := ''
	cEmail := (cPrefDef+"0")->&(cPrefDef+"0_EMAIL")

	// Busca de BROWSE
	If lBrowse
		// Chave de busca do atendente selecionado no PORTAL.
		If lVldCst //Validação campo 'CostumerKey' via classe LibPyli
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(cFabKey))

			cFiltro += IIF(!Empty(cFiltro)," AND ","")
			cFiltro += " ABA.ABA_CODFAB = '" + SA1->A1_COD +"' AND ABA.ABA_LOJAFA = '" + SA1->A1_LOJA + "' "
		EndIf
	Else
		// Busca específica do REGISTRO
		cFiltro += " ABA_NUMOS = '"+ ABA->ABA_NUMOS +"' AND ABA_CODTEC = '"+ ABA->ABA_CODTEC +"' AND ABA_SEQ = '"+ABA->ABA_SEQ+ "'"
	EndIf

	FwrestArea(aArea)

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} OrderABA
Define ordenação padrão para tabela ABA - ITENS DO ATENDIMENTO

@author  leonardo.castro
@since   23/04/2021
/*/
//-------------------------------------------------------------------
Static Function OrderABA( cOrdParam ) As Character

	Local aArea     As Array
	Local cOrdem    As Character

	DEFAULT cOrdParam := ""

	aArea := FwGetArea()

	If Empty(cOrdParam)
		cOrdem := StrTran(ABA->(IndexKey(1)),'+',',')
	Else
		cOrdem := cOrdParam
	EndIf

	FwrestArea(aArea)

Return cOrdem

//-------------------------------------------------------------------
/*/{Protheus.doc} FTotalABA

Define os totalizadores para o serviço ABA - ITENS DO ATENDIMENTO

@author  leonardo.castro
@since   28/04/2021
/*/
//-------------------------------------------------------------------
Static Function FTotalABA( oAOSItem )

	Local oJson As Object

	DEFAULT oAOSItem := JsonObject():New()

	oJson := JsonObject():New()

	// Totalizador dos Registros
	oJson['totRegistros'] := oAOSItem:oTotais

Return oJson
