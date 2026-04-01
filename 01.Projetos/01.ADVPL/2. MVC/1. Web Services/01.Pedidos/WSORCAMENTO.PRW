#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "protheus.ch"
#INCLUDE "FWMVCDef.ch"

#DEFINE CRLF CHR(13)+CHR(10)

STATIC cPrefDef := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} WSORCAMENTO

    Carrega os dados dos Orçamentos ou do registro posicionado

@author  leonardo.castro
@since   23/04/2021
/*/
//-------------------------------------------------------------------
WSRESTFUL WSORCAMENTO DESCRIPTION "EndPoint Orçamento API" FORMAT "application/json"

	WSDATA Page     	AS INTEGER
	WSDATA PageSize 	AS INTEGER
	WSDATA Token    	AS CHARACTER
	WSDATA Order    	AS CHARACTER 	OPTIONAL
	WSDATA Fields   	AS CHARACTER 	OPTIONAL
	WSDATA CompanyId  	AS CHARACTER 	OPTIONAL
	WSDATA BranchId   	AS CHARACTER 	OPTIONAL
	WSDATA CustomerKey 	AS CHARACTER 	OPTIONAL
	WSDATA BrowseSearch AS LOGICAL 		OPTIONAL
	WSDATA WHEREAPIADP 	AS CHARACTER 	OPTIONAL
	WSDATA isCopy      	AS LOGICAL 		OPTIONAL
	WSDATA filter      	AS CHARACTER 	OPTIONAL
	WSDATA device      	AS CHARACTER 	OPTIONAL

	WSMETHOD GET DESCRIPTION "Retorna uma lista de Orçamentos" WSSYNTAX "/WSORCAMENTO"
	WSMETHOD POST DESCRIPTION "Inclui determinado Orçamentos DE VENDA" WSSYNTAX "/WSORCAMENTO{?token}"
	WSMETHOD PUT DESCRIPTION "Altera determinado Orçamentos DE VENDA" WSSYNTAX "/WSORCAMENTO{?token}"
	WSMETHOD DELETE DESCRIPTION "Exclui determinado Orçamentos" WSSYNTAX "/WSORCAMENTO{?token}"

END WSRESTFUL

WSMETHOD GET WSSERVICE WSORCAMENTO

	Local lRet        As Logical
	Local oOrcamento  As Object
	Local oItems      As Object
	Local oJson       As Object
	Local oLibPyli 	  As Object
	Local cJson       As Character
	Local cEmail      As Character
	Local cID         As Character
	Local i           As Numeric
	Local lUser       As Logical
	Local aQueryParms As Array
	Local aIndexPK    As Array

	Private lVldCst   As Logical

	// API FORMAT
	Self:SetContentType('application/json')
	
	Private cAppyPyli  := ""

	If Self:device <> NIL
		cAppyPyli  := Self:device   // Armazém padrão App 33	
	EndIf

	// Query Params
	DEFAULT Self:CompanyId := ''
	DEFAULT Self:BranchId := ''
	DEFAULT Self:Token := ''
	DEFAULT Self:CustomerKey := ''
	DEFAULT Self:BrowseSearch := .T.
	DEFAULT Self:WHEREAPIADP := ''
	DEFAULT Self:isCopy := .F.
	DEFAULT Self:device := cAppyPyli

	aQueryParms := Array(0)
	For i := 1 To Len(Self:aQueryString)
		If !(Self:aQueryString[i][1] $ 'COMPANYID|BRANCHID|TOKEN|CUSTOMERKEY|BROWSESEARCH|WHEREAPIADP|ISCOPY|DEVICE|')
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
	lVldCst		:= .F.
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

	// CliAdapter é nossa CLASSE que fornece os dados dos Orçamentos ao WS
	oOrcamento := APIAdapter():New( 'GET' )

	oOrcamento:SetTable('SCJ')

	// GET Específico via ID
	If !Empty(Self:aURLParms)
		SCJ->(DbSetOrder(1))
		cID := U_FormatID(Self:aURLParms[1])
		If Empty(cID) .Or. !SCJ->(DbSeek(cID))
			SetRestFault(400,EncodeUtf8('Invalid id, registro informado Não encontrado.'))
			Return
		EndIf

		Self:Page := 1
		Self:PageSize := 1
		Self:WHEREAPIADP := ''
		Self:BrowseSearch := .F.
	EndIf

	//Define a Pagina a ser Retornada
	oOrcamento:SetPage(Self:Page)

	//Indica quantidade de registros da pagina
	oOrcamento:SetPageSize(Self:PageSize)

	//Indica a ordem definida por querystring
	//oOrcamento:SetOrderQuery(Self:Order)

	//Indica o filtro querystring recebido (pode se utilizar um filtro oData)
	oOrcamento:SetUrlFilter(aQueryParms)

	//Indica os campos que serão retornados via querystring
	oOrcamento:SetFields(Self:Fields)

	//Processa os dados dos ORCAMENTOS
	oOrcamento:SetBrowseSearch( Self:BrowseSearch )
	oOrcamento:SetFilter( FilterSCJ( Self:CustomerKey, Self:BrowseSearch ), GetFilORC() )
	oOrcamento:SetOrderAPI( OrderSCJ( Self:Order ) )
	oOrcamento:WHEREAPIADP := IIF( !Empty(Self:WHEREAPIADP), Self:WHEREAPIADP, '')
	oOrcamento:GetList()

	// Se tudo ocorreu bem, retorna os dados via Json
	If oOrcamento:lOk

		// Definição das PROPRIEDADES
		oJson['status'] := 'ok'

		// Busca de BROWSE
		If Self:BrowseSearch
			// Indica as informações das PROPRIEDADES
			oOrcamento:GetPropert()

			If ValType(oOrcamento:oTitle) == "J"
				oJson['titulo'] := oOrcamento:oTitle
			EndIf

			If ValType(oOrcamento:aOrder) == "A"
				oJson['ordem'] := oOrcamento:aOrder
			EndIf

			If ValType(oOrcamento:aOculto) == "A"
				oJson['oculto'] := oOrcamento:aOculto
			EndIf

			If ValType(oOrcamento:aApp) == "A"
				oJson['app'] := oOrcamento:aApp
			EndIf

			If ValType(oOrcamento:aLegenda) == "A"
				oJson['legenda'] := oOrcamento:aLegenda
			EndIf

			If ValType(oOrcamento:oTypeField) == "J"
				oJson['fieldTypeConfig'] := oOrcamento:oTypeField
			EndIf

			If ValType(oOrcamento:oTypeFilter) == "J"
				oJson['filtros'] := oOrcamento:oTypeFilter
			EndIf

			If ValType(oOrcamento:oHelp) == "J"
				oJson['help'] := oOrcamento:oHelp
			Endif

			If ValType(oOrcamento:oNivel) == "J"
				oJson['nivel'] := oOrcamento:oNivel
			EndIf

			// Tratamentos de ORCAMENTOS para os DADOS
			oItems:FromJson(oOrcamento:cJSON)
			If ValType(oItems) == "J"
				oJson['dados'] := oItems['items']
				oJson['hasNext'] := oItems['hasNext']
				oJson['totalPages'] := oItems['totalPages']
			EndIf
		Else

			oItems:FromJson(oOrcamento:cJSON)
			If ValType(oItems) == "J"
				oJson['dados'] := oItems['items']
			EndIf

		EndIf

		Self:SetResponse(U_EncodeETX(oJson:toJSON()))

	Else
		// Retorna o erro encontrado durante o processamento.
		SetRestFault(oOrcamento:GetCode(),oOrcamento:GetMessage())
		lRet := .F.
	EndIf

	// Desalocação dos Objetos e Arrays utilizados
	oOrcamento:DeActivate()
	oOrcamento := Nil

Return lRet

WSMETHOD POST WSSERVICE WSORCAMENTO

	Local aRet		As Array
	Local cMsg		As Character
	
	// Rotina de EXECAUTO de Orçamentos
	aRet := U_PPDData("U_PPDORCAMEN","SCJ",Self,MODEL_OPERATION_INSERT)
	cMsg := aRet[2]

	If aRet[1]
		Self:SetResponse( cMsg )
	Else
		SetRestFault( 400, cMsg, .T., 400 )
		Return
	EndIf

Return .T.

WSMETHOD PUT WSSERVICE WSORCAMENTO

	Local aRet		As Array
	Local cMsg		As Character

	// Rotina de EXECAUTO de Orçamentos
	aRet := U_PPDData("U_PPDORCAMEN","SCJ",Self,MODEL_OPERATION_UPDATE)
	cMsg := aRet[2]

	If aRet[1]
		Self:SetResponse( cMsg )
	Else
		SetRestFault( 400, cMsg, .T., 400 )
		Return
	EndIf

Return .T.

WSMETHOD DELETE WSSERVICE WSORCAMENTO

	Local aRet		As Array
	Local cMsg		As Character

	// Rotina de EXECAUTO de Orcamentos
	aRet := U_PPDData("U_PPDORCAMEN","SCJ",Self,MODEL_OPERATION_DELETE)
	cMsg := aRet[2]

	If aRet[1]
		Self:SetResponse( cMsg )
	Else
		SetRestFault( 400, cMsg, .T., 400 )
		Return
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FilterSCJ
Define filtro padrão para tabela SCJ - Orçamentos

@author  leonardo.castro
@since   23/04/2021
/*/
//-------------------------------------------------------------------
Static Function FilterSCJ( cClientKey, lBrowse ) As Character

	Local aArea     As Array
	Local cFiltro   As Character
	Local cEmail    As Character
	Local cRepVend  As Character

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
			cFiltro += "  SCJ.CJ_CLIENTE = '" + SA1->A1_COD +"' AND SCJ.CJ_LOJA = '" + SA1->A1_LOJA + "' "
		EndIf

		// Filtro de Pedidos por Representante/Usuario Logado
		cRepVend := U_FRepVendas(cEmail,"SCJ")
		If !Empty(cRepVend)
			cFiltro += IIF(!Empty(cFiltro)," AND ","")
			cFiltro += cRepVend
		EndIf
	Else
		// Busca especfica do REGISTRO
		cFiltro += " SCJ.CJ_FILIAL = '"+ SCJ->CJ_FILIAL +"' AND SCJ.CJ_NUM = '"+ SCJ->CJ_NUM +"' "
	EndIf

	FwrestArea(aArea)

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} OrderSCJ
Define ordenacao padrao para tabela SCJ - ORCAMENTOS

@author  leonardo.castro
@since   23/04/2021
/*/
//-------------------------------------------------------------------
Static Function OrderSCJ( cOrdParam ) As Character

	Local aArea     As Array
	Local cOrdem    As Character
	Local lORDBROW  As Logical

	DEFAULT cOrdParam := ''

	aArea := FwGetArea()
	lORDBROW := ExistBlock("ORDBROW")

	If Empty(cOrdParam)
		cOrdem := "CJ_FILIAL, CJ_CLIENTE, CJ_LOJA, CJ_EMISSAO DESC, CJ_NUM DESC"
		If lORDBROW
			cOrdem := ExecBlock("ORDBROW",.F.,.F.,{"SCJ",cOrdem})
		EndIf
	Else
		cOrdem := cOrdParam
	EndIf

	FwrestArea(aArea)

Return cOrdem

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldORC
    Identificacao dos CAMPOS de ORCAMENTOS

@author  leonardo.castro
@since   10/01/2022
/*/
//-------------------------------------------------------------------
Static Function FieldORC(nType)

	Local aCampos		As Array
	Local aStruct       As Array

	DEFAULT nType := 0

	aCampos := Array(0)
	aStruct := Array(0)

	Do Case
		// CABEÇALHO
	Case nType == 1

		aStruct := SCJ->(DbStruct())
		aEVAL(aStruct,{|x| aAdd(aCampos,{x[1],x[1],x[2]}) })

		// ITENS
	Case nType == 2

		// Tratamento de DELEÇÃO de GRID
		aAdd(aCampos,{"AUTDELETA","AUTDELETA","C"})

		aStruct := SCK->(DbStruct())
		aEVAL(aStruct,{|x| aAdd(aCampos,{x[1],x[1],x[2]}) })

	EndCase

Return aClone(aCampos)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPDORCAMEN

    Função AUXILIAR dos processos de INCLUSÃO/ALTERAÇÃO/EXCLUSÃO de Orçamentos

@param nOper - Operaracao do Model
@param cId   - Chave de Identificacao do registro
@param oBody - Objeto JSON contendo o corpo(body) da requisicao

@author  Leonardo.Castro
@since   10/01/2022
/*/
//-------------------------------------------------------------------
User Function PPDORCAMEN(nOper,cId,oBody)

	Local cMsg          As Character
	Local cPropertie    As Character
	Local cField        As Character
	Local cFilAux       As Character
	Local cFilOrc       As Character
	Local cNumOrc       As Character
	Local cOper         As Character
	Local cTipo         As Character
	Local cClient       As Character
	Local cLoja         As Character
	Local cLastItem     As Character
	Local cCustomerKey  As Character
	Local cCamposCJ     As Character
	Local cEmail        As Character
	Local cTabela       As Character
	Local cVendedor		As Character
	Local i             As Numeric
	Local x             As Numeric
	Local y             As Numeric
	Local nPosTab       As Numeric
	Local nPosPrunit    As Numeric
	Local nPrcUnit      As Numeric
	Local nLoop         As Numeric
	Local nPosxPyli     As Numeric
	Local aCabec        As Array
	Local aItens        As Array
	Local aLinha        As Array
	Local aOrder        As Array
	Local aPropCab      As Array
	Local aPropItem     As Array
	Local aErroAuto     As Array
	Local aIndexCabec   As Array
	Local aIndexItens   As Array
	Local aRetPee       As Array
	Local aCabAnt       As Array
	Local aIteAnt       As Array
	Local uConteud
	Local oData         As Object
	Local lCopy         As Logical
	lOCAL lApImpostos   As Logical

	PRIVATE lMsErroAuto     := .F.
	PRIVATE lMsHelpAuto     := .F.
	PRIVATE lAutoErrNoFile  := .T.

	DEFAULT cEthosxMsg := ""
	DEFAULT nOper := 3
	DEFAULT cId := ""
	DEFAULT oBody := JsonObject():New()

	// Carrega config cTabelas do Portal
	cPrefDef 	:= SuperGetMv("FS_TABWEB",.T.,"PW")
	cMsg 		:= ""
	cFilAux 	:= cFilAnt
	cFilOrc 	:= IIF(nOper==MODEL_OPERATION_INSERT,xFilial("SCJ"),SCJ->CJ_FILIAL)
	cNumOrc 	:= IIF(nOper==MODEL_OPERATION_INSERT,U_FGetCod("SCJ",1,"CJ_NUM"),SCJ->CJ_NUM)
	aIndexCabec := FieldOrc(1)
	aIndexItens := FieldOrc(2)
	cClient     := ""
	cLoja       := ""
	cTipo       := "N"
	cEmail      := (cPrefDef+"0")->&(cPrefDef+"0_EMAIL")
	cLastItem   := U_FLastItem("SCK",cId)
	aCabec      := Array(0)
	aItens      := Array(0)
	aOrder      := {"LINPOS","AUTDELETA","CK_ITEM","CK_PRODUTO","CK_DESCRI","CK_QTDVEN","CK_PRCVEN","CK_PRUNIT","CK_VALOR","C6_TES"}
	cCamposCJ	:= "CJ_FILIAL|CJ_NUM|CJ_CLIENTE|CJ_LOJA"
	aRetPee     := Array(0)
	aCabAnt     := Array(0)
	aIteAnt     := Array(0)
	cTabela     := ""
	nPosTab     := 0
	nPosPrunit  := 0
	nPrcUnit    := 0
	nLoop       := 0
	nPosxPyli   := 0
	lApImpostos := .F.
	cVendedor   := ""

	If nOper <> MODEL_OPERATION_DELETE
		oData       := oBody['data']
		aPropCab    := oData:GetNames()
		lCopy       := oBody['isCopy']
		lApImpostos := oBody['simulacaoImpostos']
	EndIf
	cCustomerKey := IF(aScan(oBody:GetNames(),"customerKey")>0,U_FormatId(oBody['customerKey']),"")

	// Chave de busca do cliente selecionado no PORTAL.
	SA1->(DbSetOrder(1))
	If !Empty(cCustomerKey) .And. SA1->(DbSeek(cCustomerKey))
		cClient := SA1->A1_COD
		cLoja   := SA1->A1_LOJA
	Else
		ConOut("---------------------------------------------------------")
		ConOut(" BODY PARAM 'customerKey' não enviado!")
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

		aAdd(aCabec,{"CJ_FILIAL" ,cFilOrc               ,Nil})

		If nOper == MODEL_OPERATION_INSERT
			aAdd(aCabec,{"CJ_CLIENTE",cClient           ,Nil})
			aAdd(aCabec,{"CJ_LOJA"   ,cLoja             ,Nil})
			If !Empty(cNumOrc)
				aAdd(aCabec,{"CJ_NUM"    ,cNumOrc           ,Nil})
			Endif
		Else
			aAdd(aCabec,{"CJ_CLIENTE",SCJ->CJ_CLIENTE   ,Nil})
			aAdd(aCabec,{"CJ_LOJA"   ,SCJ->CJ_LOJA      ,Nil})
			aAdd(aCabec,{"CJ_NUM"    ,cNumOrc           ,Nil})
		EndIf

		// MONTAGEM DO ARRAY DE CABEÇALHO
		For i := 1 To Len(aPropCab)
			cPropertie := aPropCab[i]
			If ( x := aScan(aIndexCabec, {|x| x[1] == cPropertie}) ) > 0
				cField := aIndexCabec[x][2]
				If !(cField $ cCamposCJ) .And. SCJ->(FieldPos(cField)) > 0
					uConteud := U_StruField("FORMAT", "SCJ", cField, Nil, oData[cPropertie])
					aAdd(aCabec,{cField, uConteud, Nil})
				EndIf
			EndIf
		Next i

		If nOper == MODEL_OPERATION_UPDATE
			If (nPosxPyli := aScan(aCabec,{|x| Alltrim(x[1]) == "CJ_XPYLI"})) > 0
				If aCabec[nPosxPyli][2] <> "2"
					aCabec[nPosxPyli][2] := "2"
				EndIf
			Endif
		EndIf

		// MONTAGEM DO ARRAY DE ITENS
		If aScan(aPropCab,"itens") > 0 .And. ValType(oData['itens']) == "A"
			For y := 1 To Len(oData['itens'])
				aPropItem := oData['itens'][y]:GetNames()
				aLinha := Array(0)
				For i := 1 To Len(aPropItem)
					cPropertie := aPropItem[i]
					If ( x := aScan(aIndexItens, {|x| x[1] == cPropertie}) ) > 0
						cField := aIndexItens[x][2]
						uConteud := U_StruField("FORMAT", "SCK", cField, Nil, oData['itens'][y][cPropertie])
						If cField == "AUTDELETA"
							If nOper == MODEL_OPERATION_UPDATE
								aAdd(aLinha,{"AUTDELETA", oData['itens'][y][cPropertie], Nil})
							EndIf
						ElseIf cField == 'CK_ITEM'
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
						ElseIf SCK->(FieldPos(cField)) > 0
							aAdd(aLinha,{cField, uConteud, Nil})
						EndIf
					EndIf
				Next i

				// VENDEDOR PADRÃO (Usuário Logado)
				If nOper == MODEL_OPERATION_INSERT
					SA3->(DBOrderNickname('FSEMAIL'))
					If SA3->(DbSeek(xFilial()+Lower(cEmail))) .Or. SA3->(DbSeek(xFilial()+Upper(cEmail)))
						If (x := aScan(aCabec,{|x| alltrim(x[1]) == 'CJ_VEND1'})) > 0
							If Empty(aCabec[x][2])
								aCabec[x][2] := SA3->A3_COD
							EndIf
						Else
							aAdd(aCabec,{"CJ_VEND1",SA3->A3_COD,Nil})
						EndIf
						cVendedor := SA3->A3_COD
					Else
						If (x := aScan(aCabec,{|x| alltrim(x[1]) == 'CJ_VEND1'})) > 0
							If Empty(aCabec[x][2])
								aCabec[x][2] := SA1->A1_VEND
							EndIf
						Else
							aAdd(aCabec,{"CJ_VEND1",SA1->A1_VEND,Nil})
						EndIf
						cVendedor := SA1->A1_VEND
					EndIf
				EndIf

				// ORDENAÇÃO DEFAULT(PW6) DOS CAMPOS
				U_FOrdData(@aLinha,aOrder)

				If !Empty(aLinha)
					aAdd(aItens,aLinha)
				EndIf
			Next y

			//Se for alteracao, preencho o mesmo com itens não enviados evitando a exclusao.
			If nOper == MODEL_OPERATION_UPDATE
				U_UpdItens("SCK",cNumOrc,aItens)
			EndIf

			// ORDENAÇÃO DEFAULT(PW6) DOS CAMPOS
			U_FOrdData(@aCabec,,"SCJ")

			If FindFunction("U_XPEDORC")
				aCabAnt := aClone(aCabec)
				aIteAnt := aClone(aItens)
				aRetPee := U_XPEDORC("SCJ",aCabec,aItens,nOper,lCopy,lApImpostos)
				If ValType(aRetPee) == "A" .And. Len(aRetPee) >= 3
					aCabec  := aClone(aRetPee[1])
					aItens	:= aClone(aRetPee[2])
					cNumOrc := aRetPee[3]
				EndIf
			EndIf

			// Validacao Continuacao de Execucao
			If Empty(aCabec)
				cMsgErro := "Bloqueio de regra na Validação de INCLUSÃO ou ALTERAÇÃO"
				If !Empty(cEthosxMsg)
					cMsgErro := cEthosxMsg
				EndIf
				Return {.F.,FwCutOff(cMsgErro),""}
			EndIf

			If Len(aRetPee) > 3
				cMsgErro := cEthosxMsg
				lMsErroAuto := .T.
			EndIf

		EndIf
		// EXCLUSÃO
	ElseIf nOper == MODEL_OPERATION_DELETE

		If !Empty(cFilOrc) .And. Len(cFilAnt) == Len(cFilOrc)
			cFilAnt := cFilOrc
		EndIf

		// MONTAGEM DO ARRAY DE CABECALHO
		aAdd(aCabec, {"CJ_FILIAL",  SCJ->CJ_FILIAL,     Nil})
		aAdd(aCabec, {"CJ_NUM",     SCJ->CJ_NUM,        Nil})
		aAdd(aCabec, {"CJ_TIPO",    SCJ->CJ_TIPO,       Nil})
		aAdd(aCabec, {"CJ_CLIENTE", SCJ->CJ_CLIENTE,    Nil})
		aAdd(aCabec, {"CJ_LOJA"   , SCJ->CJ_LOJA   ,    Nil})
		aAdd(aCabec, {"CJ_LOJAENT", SCJ->CJ_LOJAENT,    Nil})
		aAdd(aCabec, {"CJ_CONDPAG", SCJ->CJ_CONDPAG,    Nil})

		// MONTAGEM DO ARRAY DE ITENS
		SCK->(DbSetOrder(1)) // CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO
		If SCK->(DbSeek(xFilial("SCK",SCJ->CJ_FILIAL)+SCJ->CJ_NUM))
			While SCK->(!EoF() .And. xFilial("SCK",SCJ->CJ_FILIAL)+SCJ->CJ_NUM == CK_FILIAL+CK_NUM)
				aLinha := Array(0)
				aAdd(aLinha,{"CK_ITEM",    SCK->CK_ITEM,        Nil})
				aAdd(aLinha,{"CK_PRODUTO", SCK->CK_PRODUTO,     Nil})
				aAdd(aLinha,{"CK_QTDVEN",  SCK->CK_QTDVEN,      Nil})
				aAdd(aLinha,{"CK_PRCVEN",  SCK->CK_PRCVEN,      Nil})
				aAdd(aLinha,{"CK_PRUNIT",  SCK->CK_PRUNIT,      Nil})
				aAdd(aLinha,{"CK_VALOR",   SCK->CK_VALOR,       Nil})

				aAdd(aItens, aLinha)
				SCK->(DbSkip())
			EndDo
		EndIf

	EndIf

	If lApImpostos // Api de impostos protheus.
		cMsg := U_FSAPIMP("ORC",aCabec,aItens)
	Else
		BEGIN TRANSACTION

			MSExecAuto({|x,y,z| MATA415(x,y,z)}, aCabec, aItens, nOper)

			If !lMsErroAuto
				// Chave Identificadora
				If nOper == MODEL_OPERATION_INSERT
					cId := SCJ->&(IndexKey(1))
					cNumOrc := SCJ->CJ_NUM
					//Tratamento para atividades automaticas
					If findfunction("U_ExCrmPyl")
						U_ExCrmPyl(1/*1=nov;2=proxima*/,'SCJ','1', SCJ->CJ_CLIENTE, SCJ->CJ_LOJA, '1',cVendedor)
					Endif
				EndIf

				// Monta Mensagem padrao
				cMsg := cOper + " de Orçamento realizado com sucesso!"
				If !Empty(cNumOrc)
					cMsg += CRLF + "Número: " + cNumOrc
				Endif

				U_OrcPedMail(cNumOrc,cOper,2)

				// Muda o status do orcamento para alcada de aprovacao.
				If ExistBlock("EFETPV")
					ExecBlock("EFETPV", .F., .F.,{aCabec,aItens})
				Endif

				If Len(aCabAnt) > 0
					If (nPosTab	:= aScan(aCabAnt,{|x| alltrim(x[1]) == 'CJ_TABELA'})) > 0
						cTabela:= aCabAnt[nPosTab,2]
						SCJ->(RecLock("SCJ",.F.))
						SCJ->CJ_TABELA 	:= cTabela
						SCJ->(Msunlock())
					Endif

					DBSelectArea('SCK')
					SCK->(DbSetOrder(1))
					SCK->(DbGoTop())
					SCK->(DbSeek(SCJ->CJ_FILIAL+cNumOrc))

					While SCK->CK_NUM = cNumOrc
						If  SCK->CK_ACRESC > 0
							nPosProd := aScan(aIteAnt[1], {|x| x[1] = 'CK_PRODUTO'})
							For nLoop := 1 To Len(aIteAnt)
								If Alltrim(SCK->CK_PRODUTO) == aIteAnt[nLoop][nPosProd][2]
									If (nPosPrunit := aScan(aIteAnt[nLoop], {|x| x[1] = 'CK_PRUNIT'})) > 0
										SCK->(RECLOCK("SCK",.F.))
										SCK->CK_PRUNIT := aIteAnt[nLoop][nPosPrunit][2]
										SCK->(MSUNLOCK())
									Endif
								EndIf
							Next
						Endif
						SCK->(DbSkip())
					EndDo
				Endif

				If ExistBlock("FSCOMPORCPED") // Complemento de Orçamentos.
					ExecBlock("FSCOMPORCPED",.F.,.F.,{"SCJ",cNumOrc,nOper})
				Endif

			Else
				aErroAuto := GetAutoGRLog()
				For i := 1 To Len(aErroAuto)
					cMsg += StrTran(StrTran(aErroAuto[i], "<", ""), "-", "") + " " + CRLF
				Next i

				If Empty(cMsg)
					cMsg := "Não foi possivel realizar a " + cOper + " do Orçamento!"
				EndIf
			EndIf

			If !lMsErroAuto .And. nOper == MODEL_OPERATION_INSERT .And. ExistBlock("PVMSGINC")
				cMsg := ExecBlock("PVMSGINC",.F.,.F.,{.F.,cMsg,cNumOrc})
			EndIf

			// Mensagem customizada
			If ValType("cEthosxMsg") <> 'U' .And. !Empty(cEthosxMsg)
				cMsg := cEthosxMsg
			EndIf

		END TRANSACTION
	Endif

	// Restaura Filial LOGADA
	cFilAnt := cFilAux

Return {!lMsErroAuto,cMsg}

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
