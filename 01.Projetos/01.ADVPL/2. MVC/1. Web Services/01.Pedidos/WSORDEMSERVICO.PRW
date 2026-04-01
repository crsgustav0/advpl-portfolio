#INCLUDE "totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "RESTFUL.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "FWMVCDef.ch"

#DEFINE CRLF CHR(13)+CHR(10)

STATIC cPrefDef := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} WSORDEMSERVICO
Carrega os dados das ORDENS DE SERVIÇOS ou do registro posicionado
@author  leonardo.castro
@since   23/04/2021
/*/
//-------------------------------------------------------------------
WSRESTFUL WSORDEMSERVICO DESCRIPTION "EndPoint ORDEM DE SERVIÇO API" FORMAT "application/json"

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

	WSMETHOD GET DESCRIPTION "Retorna uma lista de ORDENS DE SERVIÇO" WSSYNTAX "/WSORDEMSERVICO"
	WSMETHOD POST DESCRIPTION "Inclui determinada ORDEM DE SERVIÇO" WSSYNTAX "/WSORDEMSERVICO{?token}"
	WSMETHOD PUT DESCRIPTION "Altera determinada ORDEM DE SERVIÇO" WSSYNTAX "/WSORDEMSERVICO{?token}"
	WSMETHOD DELETE DESCRIPTION "Exclui determinada ORDEM DE SERVIÇO" WSSYNTAX "/WSORDEMSERVICO{?token}"

END WSRESTFUL

WSMETHOD GET WSSERVICE WSORDEMSERVICO

	Local lRet          As Logical
	Local oOServico     As Object
	Local oItems        As Object
	Local oJson         As Object
	Local oLibPyli      As Object
	Local cJson         As Character
	Local cEmail        As Character
	Local cID           As Character
	Local i             As Numeric
	Local lUser         As Logical
	Local aQueryParms   As Array
	Local aIndexPK      As Array

	Local lVldCst       AS Logical

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
	aIndexPK    := Array(0)
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

	// CliAdapter é nossa CLASSE que fornece os dados das OS ao WS
	oOServico := APIAdapter():New( 'GET' )

	oOServico:SetTable('AB6')

	// GET Específico via ID
	If !Empty(Self:aURLParms)
		AB6->(DbSetOrder(1))
		cID := U_FormatID(Self:aURLParms[1])
		If Empty(cID) .Or. !AB6->(DbSeek(cID))
			SetRestFault(400,EncodeUtf8('Invalid id, registro informado não encontrado.'))
			Return
		EndIf

		Self:Page := 1
		Self:PageSize := 1
		Self:WHEREAPIADP := ''
		Self:BrowseSearch := .F.
	EndIf

	//Define a Pagina a ser Retornada
	oOServico:SetPage(Self:Page)

	//Indica quantidade de registros da pagina
	oOServico:SetPageSize(Self:PageSize)

	//Indica a ordem definida por querystring
	//oOServico:SetOrderQuery(Self:Order)

	//Indica o filtro querystring recebido (pode se utilizar um filtro oData)
	oOServico:SetUrlFilter(aQueryParms)

	//Indica os campos que serão retornados via querystring
	//oOServico:SetFields(Self:Fields)

	//Processa os dados das OS
	oOServico:SetBrowseSearch( Self:BrowseSearch )
	oOServico:SetFilter( FilterAB6( Self:CustomerKey, Self:BrowseSearch ), GetFilOS() )
	oOServico:SetOrderAPI( OrderAB6( Self:Order ) )
	oOServico:WHEREAPIADP := IIF( !Empty(Self:WHEREAPIADP), Self:WHEREAPIADP, '')

	//Executa Processo de Listagem
	oOServico:GetList()

	// Se tudo ocorreu bem, retorna os dados via Json
	If oOServico:lOk

		// Definição das PROPRIEDADES
		oJson['status'] := 'ok'

		// Busca de BROWSE
		If Self:BrowseSearch
			// Indica as informações das PROPRIEDADES
			oOServico:GetPropert()

			If ValType(oOServico:oTitle) == "J"
				oJson['titulo'] := oOServico:oTitle
			EndIf

			If ValType(oOServico:aOrder) == "A"
				oJson['ordem'] := oOServico:aOrder
			EndIf

			If ValType(oOServico:aOculto) == "A"
				oJson['oculto'] := oOServico:aOculto
			EndIf

			If ValType(oOServico:aApp) == "A"
				oJson['app'] := oOServico:aApp
			EndIf

			If ValType(oOServico:aLegenda) == "A"
				oJson['legenda'] := oOServico:aLegenda
			EndIf

			If ValType(oOServico:oTypeField) == "J"
				oJson['fieldTypeConfig'] := oOServico:oTypeField
			EndIf

			If ValType(oOServico:oTypeFilter) == "J"
				oJson['filtros'] := oOServico:oTypeFilter
			EndIf

			If ValType(oOServico:oHelp) == "J"
				oJson['help'] := oOServico:oHelp
			EndIf

			If ValType(oOServico:oNivel) == "J"
				oJson['nivel'] := oOServico:oNivel
			EndIf

			// Tratamentos de ORDEM DE SERVIÇO para os DADOS
			oItems:FromJson(oOServico:cJSON)
			If ValType(oItems) == "J"
				oJson['dados'] := oItems['items']
				oJson['hasNext'] := oItems['hasNext']
				oJson['totalPages'] := oItems['totalPages']
			EndIf

		Else

			oItems:FromJson(oOServico:cJSON)
			If ValType(oItems) == "J"
				// Montagem de Array dos Itens do Ordem de Serviço
				oJson['dados'] := FBuildItem( Self, oItems['items'] )
			EndIf

		EndIf

		Self:SetResponse(U_EncodeETX(oJson:toJSON()))

	Else
		// Retorna o erro encontrado durante o processamento.
		SetRestFault(oOServico:GetCode(),oOServico:GetMessage())
		lRet := .F.
	EndIf

	// Desalocação dos Objetos e Arrays utilizados
	oOServico:DeActivate()
	oOServico := Nil

Return lRet

WSMETHOD POST WSSERVICE WSORDEMSERVICO

	Local aRet		As Array
	Local cMsg		As Character

	// Rotina de EXECAUTO de ORDENS DE SERVIÇO
	aRet := U_PPDData("U_PPDOSERVICO","AB6",Self,MODEL_OPERATION_INSERT)
	cMsg := aRet[2]

	If aRet[1]
		Self:SetResponse( cMsg )
	Else
		SetRestFault( 400, cMsg, .T., 400 )
		Return
	EndIf

Return .T.

WSMETHOD PUT WSSERVICE WSORDEMSERVICO

	Local aRet		As Array
	Local cMsg		As Character

	// Rotina de EXECAUTO de ORDENS DE SERVIÇO
	aRet := U_PPDData("U_PPDOSERVICO","AB6",Self,MODEL_OPERATION_UPDATE)
	cMsg := aRet[2]

	If aRet[1]
		Self:SetResponse( cMsg )
	Else
		SetRestFault( 400, cMsg, .T., 400 )
		Return
	EndIf

Return .T.

WSMETHOD DELETE WSSERVICE WSORDEMSERVICO

	Local aRet		As Array
	Local cMsg		As Character

	// Rotina de EXECAUTO de ORDENS DE SERVIÇO
	aRet := U_PPDData("U_PPDOSERVICO","AB6",Self,MODEL_OPERATION_DELETE)
	cMsg := aRet[2]

	If aRet[1]
		Self:SetResponse( cMsg )
	Else
		SetRestFault( 400, cMsg, .T., 400 )
		Return
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FilterAB6
Define filtro padrão para tabela AB6 - ORDEM DE SERVIÇO

@author  leonardo.castro
@since   23/04/2021
/*/
//-------------------------------------------------------------------
Static Function FilterAB6( cClientKey, lBrowse ) As Character

	Local aArea     As Array
	Local cFiltro   As Character
	Local cEmail    As Character

	DEFAULT cClientKey := ''
	DEFAULT lBrowse := .F.

	aArea   := FwGetArea()
	cFiltro := ''
	cEmail := (cPrefDef+"0")->&(cPrefDef+"0_EMAIL")

	// Busca de BROWSE
	If lBrowse
		// Chave de busca do cliente selecionado no PORTAL.
		If lVldCst //Validação campo 'CostumerKey' via classe LibPyli
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(cClientKey))

			cFiltro += IIF(!Empty(cFiltro)," AND ","")
			cFiltro += " AB6.AB6_CODCLI = '" + SA1->A1_COD +"' AND AB6.AB6_LOJA = '" + SA1->A1_LOJA + "' "
		EndIf

	Else
		// Busca específica do REGISTRO
		cFiltro += " AB6.AB6_NUMOS = '"+ AB6->AB6_NUMOS +"' "
	EndIf

	FwrestArea(aArea)

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} OrderAB6
Define ordenação padrão para tabela AB6 - ORDEM DE SERVIÇO

@author  leonardo.castro
@since   23/04/2021
/*/
//-------------------------------------------------------------------
Static Function OrderAB6( cOrdParam ) As Character

	Local aArea     As Array
	Local cOrdem    As Character
	Local lOrdBrow  As Logical

	DEFAULT cOrdParam := ''

	aArea    := FwGetArea()
	lOrdBrow := ExistBlock("ORDBROW")

	If Empty(cOrdParam)
		If lOrdBrow
			cOrdem := ExecBlock("ORDBROW",.F.,.F.,{"AB6",cOrdem})
		else
			cOrdem := "AB6_FILIAL, AB6_CODCLI, AB6_LOJA, AB6_EMISSA DESC, AB6_NUMOS DESC"
		EndIf
	Else
		cOrdem := cOrdParam
	Endif

	FwrestArea(aArea)

Return cOrdem

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldOS
    Identificação dos CAMPOS de OS

@author  leonardo.castro
@since   10/01/2022
/*/
//-------------------------------------------------------------------
Static Function FieldOS(nType)

	Local aCampos		As Array
	Local aStruct       As Array

	DEFAULT nType := 0

	aCampos := Array(0)
	aStruct := Array(0)

	Do Case
		// CABEÇALHO
	Case nType == 1

        /* IMPLEMENTAÇÃO DE NOMES DE PROPRIEDADES
            aAdd(aCampos,{"codigo"              ,"AB6_NUMOS"               ,"C"})
        */
		aStruct := AB6->(DbStruct())
		aEVAL(aStruct,{|x| aAdd(aCampos,{x[1],x[1],x[2]}) })

		// ITENS
	Case nType == 2

        /*
            aAdd(aCampos,{"codigo"              ,"AB7_NUMOS"              ,"C"})
        */

		aStruct := AB7->(DbStruct())
		aEVAL(aStruct,{|x| aAdd(aCampos,{x[1],x[1],x[2]}) })

		// Tratamento de DELEÇÃO de GRID
		aAdd(aCampos,{"AUTDELETA","AUTDELETA","C"})

	EndCase

Return aClone(aCampos)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPDOServico
    Função AUXILIAR dos processos de INCLUSÃO/ALTERAÇÃO/EXCLUSÃO de

    ORDENS DE SERVIÇO

@param nOper - Operação do Model
@param cId   - Chave Identificadora do registro
@param oBody - Objeto JSON contendo o corpo(body) da requisição

@author  Leonardo.Castro
@since   10/01/2022
/*/
//-------------------------------------------------------------------
User Function PPDOServico(nOper,cId,oBody)

	Local cMsg          As Character
	Local cPropertie    As Character
	Local cField        As Character
	Local cNumOS        As Character
	Local cOper         As Character
	Local cTipo         As Character
	Local cClient       As Character
	Local cLoja         As Character
	Local cLastItem     As Character
	Local cCustomerKey  As Character
	Local cCampoAB6     As Character
	Local i             As Numeric
	Local x             As Numeric
	Local y             As Numeric
	Local aCabec        As Array
	Local aItens        As Array
	Local aLinha        As Array
	Local aOrder        As Array
	Local aPropCab      As Array
	Local aPropItem     As Array
	Local aErroAuto     As Array
	Local aIndexCabec   As Array
	Local aIndexItens   As Array
	Local uConteud
	Local oData         As Object

	PRIVATE lMsErroAuto    := .F.
	PRIVATE lMsHelpAuto     := .F.
	PRIVATE lAutoErrNoFile  := .T.

	DEFAULT nOper := 3
	DEFAULT cId := ""
	DEFAULT oBody := JsonObject():New()

	cMsg := ""
	cNumOS := IIF(nOper==MODEL_OPERATION_INSERT,U_FGetCod("AB6",1,"AB6_NUM"),AB6->AB6_NUM)
	aIndexCabec := FieldOS(1)
	aIndexItens := FieldOS(2)
	cClient := ""
	cLoja := ""
	cTipo := "N"
	cLastItem := U_FLastItem("AB7",cId)
	aOrder := {"LINPOS","AUTDELETA","AB7_ITEM","AB7_TIPO","AB7_CODPRO","AB7_NUMSER","AB7_QTDSEP","AB7_CODPRB","AB7_CODCON"}
	cCampoAB6 := "AB6_FILIAL|AB6_NUM|AB6_CODCLI|AB6_LOJA"
	If nOper <> MODEL_OPERATION_DELETE
		oData := oBody['data']
		aPropCab := oData:GetNames()
	Endif
	cCustomerKey := IF(aScan(oBody:GetNames(),"customerKey")>0,U_FormatId(oBody['customerKey']),"")
	aCabec := Array(0)
	aLinha := Array(0)
	aItens := Array(0)

	// Chave de busca do cliente selecionado no PORTAL.
	SA1->(DbSetOrder(1))
	If !Empty(cCustomerKey) .And. SA1->(DbSeek(cCustomerKey))
		cClient := SA1->A1_COD
		cLoja   := SA1->A1_LOJA
	Else
		ConOut("---------------------------------------------------------")
		ConOut(" BODY PARAM 'customerKey' não encontrado!")
		ConOut("---------------------------------------------------------")
	EndIf

	Do Case
	Case nOper == MODEL_OPERATION_INSERT
		cOper   := "Inclusão"
	Case nOper == MODEL_OPERATION_UPDATE
		cOper   := "Alteração"
	Case nOper == MODEL_OPERATION_DELETE
		cOper   := "Exclusão"
	OtherWise
		cOper   := ""
	EndCase

	// INCLUSÃO e ALTERAÇÃO
	If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE

		aAdd(aCabec,{"AB6_FILIAL" ,xFilial("AB6")    ,Nil})
		aAdd(aCabec,{"AB6_NUMOS"    ,cNumOS           ,Nil})
		If nOper == MODEL_OPERATION_INSERT
			aAdd(aCabec,{"AB6_CODCLI",cClient           ,Nil})
			aAdd(aCabec,{"AB6_LOJA",cLoja             ,NABil})
		EndIf

		// MONTAGEM DO ARRAY DE CABEÇALHO
		For i := 1 To Len(aPropCab)
			cPropertie := aPropCab[i]
			If ( x := aScan(aIndexCabec, {|x| x[1] == cPropertie}) ) > 0
				cField := aIndexCabec[x][2]
				If !(cField $ cCampoAB6) .And. AB6->(FieldPos(cField)) > 0
					uConteud := U_StruField("FORMAT", "AB6", cField, Nil, oData[cPropertie])
					aAdd(aCabec,{cField, uConteud, Nil})
				EndIf
			EndIf
		Next i

		// MONTAGEM DO ARRAY DE ITENS
		If aScan(aPropCab,"itens") > 0 .And. ValType(oData['itens']) == "A"
			For y := 1 To Len(oData['itens'])
				aPropItem := oData['itens'][y]:GetNames()
				aLinha := Array(0)
				For i := 1 To Len(aPropItem)
					cPropertie := aPropItem[i]
					If ( x := aScan(aIndexItens, {|x| x[1] == cPropertie}) ) > 0
						cField := aIndexItens[x][2]
						uConteud := U_StruField("FORMAT", "AB7", cField, Nil, oData['itens'][y][cPropertie])
						If cField == "AUTDELETA"
							If nOper == MODEL_OPERATION_UPDATE
								aAdd(aLinha,{"AUTDELETA", oData['itens'][y][cPropertie], Nil})
							EndIf
						ElseIf cField == 'AB7_ITEM'
							If nOper == MODEL_OPERATION_INSERT
								If uConteud == "&&"
									uConteud := ( cLastItem := Soma1(cLastItem) )
								EndIf
								aAdd(aLinha,{cField, uConteud, Nil})
							ElseIf nOper == MODEL_OPERATION_UPDATE
								If uConteud == "&&"
									uConteud := ( cLastItem := Soma1(cLastItem) )
									aAdd(aLinha,{cField, uConteud, Nil})
								Else
									aAdd(aLinha,{"LINPOS", cField, uConteud})
								EndIf
							EndIf
						ElseIf AB7->(FieldPos(cField)) > 0
							aAdd(aLinha,{cField, uConteud, Nil})
						EndIf
					EndIf
				Next i

				// INFORMAÇÕES DEFAULT DAS OS DE VENDA
				If nOper == MODEL_OPERATION_UPDATE
					U_FPDefALT("AB6",aCabec,aLinha)
				EndIf

				// ORDENAÇÃO DEFAULT DOS CAMPOS
				U_FOrdData(@aLinha,aOrder)

				If !Empty(aLinha)
					aAdd(aItens,aLinha)
				EndIf
			Next y

			//Se for alteração, preencho o mesmo com itens não enviados evitando a exclusão.
			//If nOper == MODEL_OPERATION_UPDATE
			//U_UpdItens("AB7",cNumOS,aItens)
			//EndIf

			// ORDENAÇÃO DEFAULT(PW6) DOS CAMPOS
			U_FOrdData(@aCabec,,"AB6")

		EndIf

		// EXCLUSÃO
	ElseIf nOper == MODEL_OPERATION_DELETE

		// MONTAGEM DO ARRAY DE CABEÇALHO
		aAdd(aCabec, {"AB6_FILIAL",  AB6->AB6_FILIAL,     Nil})
		aAdd(aCabec, {"AB6_NUMOS",     AB6->AB6_NUMOS,        Nil})
		aAdd(aCabec, {"AB6_CODCLI", AB6->AB6_CODCLI,    Nil})
		aAdd(aCabec, {"AB6_LOJA", AB6->AB6_LOJA,    Nil})
		aAdd(aCabec, {"AB6_CONPAG", AB6->AB6_CONPAG,    Nil})
		aAdd(aCabec, {"AB6_CONDPAG", AB6->AB6_CONDPAG,    Nil})

		// MONTAGEM DO ARRAY DE ITENS
		AB7->(DbSetOrder(1)) // AB7_FILIAL, AB7_NUMOS, AB7_ITEM, AB7_TIPO
		If AB7->(DbSeek(xFilial("AB7")+AB6->AB6_NUM))
			While AB7->(!EoF() .And. xFilial("AB7")+AB6->AB6_NUM == AB7_FILIAL+AB7_NUMOS)
				aLinha := Array(0)
				aAdd(aLinha,{"AB7_ITEM",    AB7->AB7_ITEM,        Nil})
				aAdd(aLinha,{"AB7_TIPO",    AB7->AB7_TIPO,        Nil})
				aAdd(aLinha,{"AB7_CODPRO",  AB7->AB7_CODPRO,      Nil})
				aAdd(aLinha,{"AB7_NUMSER",  AB7->AB7_NUMSER,      Nil})
				aAdd(aLinha,{"AB7_QTDSEP",  AB7->AB7_QTDSEP,      Nil})
				aAdd(aLinha,{"AB7_CODPRB",  AB7->AB7_CODPRB,      Nil})
				aAdd(aLinha,{"AB7_CODCON",  AB7->AB7_CODCON,      Nil})

				aAdd(aItens, aLinha)
				AB7->(DbSkip())
			EndDo
		EndIf

	EndIf

	BEGIN TRANSACTION

		MSExecAuto({|x,y,z| TECA450(x,y,z)}, aCabec, aItens, nOper)

		If !lMsErroAuto
			// Chave Identificadora
			If nOper == MODEL_OPERATION_INSERT
				cId := AB6->&(IndexKey(1))
			EndIf

			// Monta Mensagem padrão
			cMsg := cOper + " de Ordem de Serviço realizada com sucesso!"
			If !Empty(cNumOS)
				cMsg += CRLF + "NÚMERO: " + cNumOS
			Endif
		Else
			aErroAuto := GetAutoGRLog()
			For i := 1 To Len(aErroAuto)
				cMsg += StrTran(StrTran(aErroAuto[i], "<", ""), "-", "") + " " + CRLF
			Next i

			If Empty(cMsg)
				cMsg := "Não foi possivel realizar a " + cOper + " do Ordem de Serviço!"
			EndIf
		EndIf

		// Mensagem customizada
		If Type("cEthosxMsg") <> 'U' .And. !Empty(cEthosxMsg)
			cMsg := cEthosxMsg
		EndIf

	END TRANSACTION

Return {!lMsErroAuto,cMsg}

//-------------------------------------------------------------------
/*/{Protheus.doc} FBuildItem
    Função AUXILIAR de Requisição para busca dos Itens da OS

@param oSelf - Objeto WSRESTFUL
@param aOServico - Array do tipo JsonObject de OS

@author  Leonardo.Castro
@since   10/01/2022
/*/
//-------------------------------------------------------------------
Static Function FBuildItem( oSelf, aOServico )

	Local cUrl          As Character
	Local cParam        As Character
	Local oJson         As Object
	Local oRest         As Object
	Local ototReg       As Object
	Local aDados        As Array
	Local aHeadOut      As Array

	oJson := JsonObject():New()
	ototReg := JsonObject():New()
	aDados := Array(0)
	aHeadOut := Array(0)
	cUrl := ''
	cParam := ''

	// Header da Request
	aAdd(aHeadOut,'Content-Type: application/json')
	aAdd(aHeadOut,'Content-Type: text/plain')
	aAdd(aHeadOut,'Accept: */*')
	aAdd(aHeadOut,'Connection: keep-alive')
	aAdd(aHeadOut,'cache-control: no-cache')

	cUrl    := oSelf:GetUrl()
	cUrl    := Stuff(cUrl,len(cUrl),1,"")
	oRest   := FWRest():New(cUrl)

	cParam  := "/WSOSITEM?branchId="+cFilAnt+"&companyId="+cEmpAnt+"&token=" + oSelf:Token + "&BrowseSearch=false&filter=AB7_NUMOS+eq+"+aOServico[1]['ab6_numos']
	cParam  := StrTran(cParam,' ', '%20')
	oRest:setPath(cParam)

	If oRest:Get(aHeadOut)
		oJson:FromJson(oRest:GetResult())
		aDados := oJson['dados']
		ototReg := oJson['totalizadores']['totRegistros']
	Else
		ConOut("Falha Requisição WSOSITEM, ERRO: "+FwNoAccent(EncodeUTF8(oRest:GetLastError())))
	EndIf

	aOServico[1]['itens'] := aDados
	aOServico[1]['totReg'] := ototReg

Return aOServico

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilOS

    Retorna lista de filiais dos OS

@author  leonardo.castro
@since   12/05/2021
/*/
//-------------------------------------------------------------------
Static Function GetFilOS()

	Local cFil As Character

	cFil := U_FGetPropert( (cPrefDef+"0")->&(cPrefDef+"0_CODIGO"), "defaultBranchOS" )

	If Empty(cFil)
		cFil := FWxFilial("AB6")
	EndIf

Return cFil
