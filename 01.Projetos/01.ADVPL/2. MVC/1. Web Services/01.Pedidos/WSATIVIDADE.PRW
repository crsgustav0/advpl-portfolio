#INCLUDE "totvs.ch"
#INCLUDE "RESTFUL.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "FWMVCDef.ch"

STATIC cPrefDef := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} WSATIVIDADE
Carrega os dados das atividade dos AOF Suspects e Prospects
@author  Jose.Gavetti
@since   02/09/2024
/*/
//-------------------------------------------------------------------
WSRESTFUL WSATIVIDADE DESCRIPTION "EndPoint ATIVIDADE API" FORMAT "application/json"

	WSDATA Page         AS INTEGER
	WSDATA PageSize     AS INTEGER
	WSDATA Token        AS CHARACTER
	WSDATA Order        AS CHARACTER OPTIONAL
	WSDATA Fields       AS CHARACTER OPTIONAL
	WSDATA CompanyId    AS CHARACTER OPTIONAL
	WSDATA BranchId     AS CHARACTER OPTIONAL
	WSDATA CustomerKey  AS CHARACTER OPTIONAL
	WSDATA BrowseSearch AS LOGICAL OPTIONAL
	WSDATA WHEREAPIADP  AS CHARACTER OPTIONAL
	WSDATA isCopy       AS LOGICAL OPTIONAL

	WSMETHOD GET DESCRIPTION "Retorna uma lista de ATIVIDADE" WSSYNTAX "/WSATIVIDADE"
	WSMETHOD POST DESCRIPTION "Inclui determinado ATIVIDADE" WSSYNTAX "/WSATIVIDADE{?token}"
	WSMETHOD PUT DESCRIPTION "Altera determinado ATIVIDADE" WSSYNTAX "/WSATIVIDADE{?token}"
	WSMETHOD DELETE DESCRIPTION "Exclui determinado ATIVIDADE" WSSYNTAX "/WSATIVIDADE{?token}"

END WSRESTFUL

WSMETHOD GET WSSERVICE WSATIVIDADE

	Local lRet          As Logical
	Local oAtividade    As Object
	Local oItems        As Object
	Local oJson         As Object
	Local oLibPyli 	    As Object
	Local cJson         As Character
	Local cEmail        As Character
	Local i             As Numeric
	Local lUser         As Logical
	Local aQueryParms   As Array

	Private lVldCst		As Logical

	// API FORMAT
	Self:SetContentType('application/json')

	// Query Params
	If ValType(Self:CompanyId) == "U"
		Self:CompanyId := ''
	EndIf
	If ValType(Self:BranchId) == "U"
		Self:BranchId := ''
	EndIf
	If ValType(Self:Token) == "U"
		Self:Token := ''
	EndIf
	If ValType(Self:WHEREAPIADP) == "U"
		Self:WHEREAPIADP := ''
	EndIf

	aQueryParms := Array(0)
	For i := 1 To Len(Self:aQueryString)
		If !(Self:aQueryString[i][1] $ 'COMPANYID|BRANCHID|TOKEN|WHEREAPIADP')
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
	lUser       := .F.
	Self:CustomerKey := U_FormatId(Self:CustomerKey)
	Self:BrowseSearch := U_FormatL(Self:BrowseSearch)

	//Validação código cliente para filtro de registros
	lVldCst := oLibPyli:FsVldCst(Self:CustomerKey)

	// Carrega config cTabelas do Portal
	cPrefDef := SuperGetMv("FS_TABWEB",.T.,"PW")

	DbSelectArea(cPrefDef+"0")
	(cPrefDef+"0")->(DbSetOrder(2))

	lUser  := oLibPyli:ValidUser(Self:Token)

	If !lUser
		SetRestFault(400,EncodeUtf8('Invalid Token, validação de usuário incorreta.'))
		Return
	EndIf

	// CliAdapter é nossa CLASSE que fornece os dados dos ATIVIDADE ao WS
	oAtividade := APIAdapter():New( 'GET' )

	//Define a Pagina a ser Retornada
	oAtividade:SetPage(Self:Page)

	//Indica quantidade de registros da pagina
	oAtividade:SetPageSize(Self:PageSize)

	//Indica o filtro querystring recebido (pode se utilizar um filtro oData)
	oAtividade:SetUrlFilter(aQueryParms)

	//Indica os campos que serão retornados via querystring
	oAtividade:SetFields(Self:Fields)

	//Processa os dados dos ATIVIDADE
	oAtividade:SetTable('AOF')
	oAtividade:SetFilter( FilterAOF(Self:CustomerKey, Self:BrowseSearch) )
	oAtividade:SetOrderAPI( OrderAOF( Self:Order ) )
	oAtividade:WHEREAPIADP := IIF( !Empty(Self:WHEREAPIADP), Self:WHEREAPIADP, '')
	oAtividade:GetList()

	// Se tudo ocorreu bem, retorna os dados via Json
	If oAtividade:lOk

		// Indica as informações das PROPRIEDADES
		oAtividade:GetPropert()

		// Definição das PROPRIEDADES
		oJson['status'] := 'ok'

		If ValType(oAtividade:oTitle) == "J"
			oJson['titulo'] := oAtividade:oTitle
		EndIf

		If ValType(oAtividade:aOrder) == "A"
			oJson['ordem'] := oAtividade:aOrder
		EndIf

		If ValType(oAtividade:aOculto) == "A"
			oJson['oculto'] := oAtividade:aOculto
		EndIf

		If ValType(oAtividade:aApp) == "A"
			oJson['app'] := oAtividade:aApp
		EndIf

		If ValType(oAtividade:aLegenda) == "A"
			oJson['legenda'] := oAtividade:aLegenda
		EndIf

		If ValType(oAtividade:oTypeField) == "J"
			oJson['fieldTypeConfig'] := oAtividade:oTypeField
		EndIf

		If ValType(oAtividade:oTypeFilter) == "J"
			oJson['filtros'] := oAtividade:oTypeFilter
		EndIf

		If ValType(oAtividade:oHelp) == "J"
			oJson['help'] := oAtividade:oHelp
		EndIf

		If ValType(oAtividade:oNivel) == "J"
			oJson['nivel'] := oAtividade:oNivel
		EndIf

		// Tratamentos de ATIVIDADE para os DADOS
		oItems:FromJson(oAtividade:cJSON)
		If ValType(oItems) == "J"
			oJson['dados'] := oItems['items']
			oJson['hasNext'] := oItems['hasNext']
			oJson['totalPages'] := oItems['totalPages']
		EndIf

		Self:SetResponse(U_EncodeETX(oJson:toJSON()))

	Else
		// Retorna o erro encontrado durante o processamento.
		SetRestFault(oAtividade:GetCode(),oAtividade:GetMessage())
		lRet := .F.
	EndIf

	// Desalocação dos Objetos e Arrays utilizados
	oAtividade:DeActivate()
	oAtividade := Nil

Return lRet


WSMETHOD POST WSSERVICE WSATIVIDADE

	Local aRet		As Array
	Local cMsg		As Character

	// Rotina de EXECAUTO de ATIVIDADE
	aRet := U_PPDData("U_PDDATIVIDADE","AOF",Self,MODEL_OPERATION_INSERT)
	cMsg := aRet[2]

	If aRet[1]
		Self:SetResponse( cMsg )
	Else
		SetRestFault( 400, cMsg, .T., 400 )
		Return
	EndIf

Return .T.

WSMETHOD PUT WSSERVICE WSATIVIDADE

	Local aRet		As Array
	Local cMsg		As Character

	// Rotina de EXECAUTO de ATIVIDADE
	aRet := U_PPDData("U_PDDATIVIDADE","AOF",Self,MODEL_OPERATION_UPDATE)
	cMsg := aRet[2]

	If aRet[1]
		Self:SetResponse( cMsg )
	Else
		SetRestFault( 400, cMsg, .T., 400 )
		Return
	EndIf

Return .T.

WSMETHOD DELETE WSSERVICE WSATIVIDADE

	Local aRet		As Array
	Local cMsg		As Character

	// Rotina de EXECAUTO de ATIVIDADE
	aRet := U_PPDData("U_PDDATIVIDADE","AOF",Self,MODEL_OPERATION_DELETE)
	cMsg := aRet[2]

	If aRet[1]
		Self:SetResponse( cMsg )
	Else
		SetRestFault( 400, cMsg, .T., 400 )
		Return
	EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} FilterAOF
Define filtro padrão para tabela AOF - ATIVIDADE

@author  Jose.Gavetti
@since  02/09/2024
/*/
//-------------------------------------------------------------------
Static Function FilterAOF(cClientKey,lBrowse) As Character

	Local aArea     As Array
	Local cFiltro   As Character
	Local cEmail    As Character
	Local cTipoUsr  As Character
	Local cVend 	As Character

	aArea    := FwGetArea()
	cFiltro  := ''
	cVend    := ''
	cEmail   := (cPrefDef+"0")->&(cPrefDef+"0_EMAIL")
	cTipoUsr := (cPrefDef+"0")->&(cPrefDef+"0_TIPO")

	// Busca de BROWSE
	If lBrowse
		// Chave de busca do cliente selecionado no PORTAL.
		If lVldCst  //Validação campo 'CostumerKey' via classe LibPyli
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(cClientKey))

			cFiltro += IIF(!Empty(cFiltro)," AND ","")
			cFiltro += " AOF.AOF_CODCLI = '" + SA1->A1_COD + "' "
		EndIf
	Else
		If cTipoUsr == '1'
			If !Empty(cEmail)
				SA3->(DbOrderNickName('FSEMAIL'))
				If SA3->(DbSeek(xFilial('SA3') + Lower(Alltrim(cEmail)))) .Or. SA3->(DbSeek(xFilial('SA3') + Upper(Alltrim(cEmail))))
					cVend := SA3->A3_COD
				EndIf
			EndIf

			If AOF->(FieldPos("AOF_XVEND")) > 0 .and. !Empty(cVend)
				cFiltro += IIF(!Empty(cFiltro)," AND ","")
				cFiltro += " AOF.AOF_XVEND = '"+ cVend +"' "
			EndIf
		Endif
	EndIf

	FwrestArea(aArea)

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} OrderAOF
Define ordenação padrão para tabela AOF - ATIVIDADE

@author  Jose.Gavetti
@since   02/09/2024
/*/
//-------------------------------------------------------------------
Static Function OrderAOF( cOrdParam ) As Character

	Local aArea     As Array
	Local cOrdem    As Character
	Local lORDBROW  As Logical

	DEFAULT cOrdParam := ''

	aArea := FwGetArea()
	lORDBROW := ExistBlock("ORDBROW")

	If Empty(cOrdParam)
		cOrdem := " AOF_DTFIM "
		If lORDBROW
			cOrdem := ExecBlock("ORDBROW",.F.,.F.,{"AOF",cOrdem})
		EndIf
	Else
		cOrdem := cOrdParam
	EndIf

	FwrestArea(aArea)

Return cOrdem


//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPros
    Identificação dos CAMPOS de ATIVIDADE

@author  Jose.Gavetti
@since   02/09/2024
/*/
//-------------------------------------------------------------------
Static Function FieldPros(nType)

	Local aCampos		As Array
	Local aStruct       As Array

	DEFAULT nType := 0

	aCampos := Array(0)
	aStruct := Array(0)

	Do Case
		// CABEÇALHO
	Case nType == 1

		aStruct := AOF->(DbStruct())
		aEVAL(aStruct,{|x| aAdd(aCampos,{x[1],x[1],x[2]}) })

	EndCase

Return aClone(aCampos)

//-------------------------------------------------------------------
/*/{Protheus.doc} PDDATIVIDADE
    Função AUXILIAR dos processos de INCLUSÃO/ALTERAÇÃO/EXCLUSÃO de ATIVIDADE

@param nOper - Operação do Model
@param cId   - Chave Identificadora do registro
@param oBody - Objeto JSON contendo o corpo(body) da requisição

@author  Jose.Gavetti
@since   07/05/2021
/*/
//-------------------------------------------------------------------
User Function PDDATIVIDADE(nOper,cId,oBody)

	Local aArea     	As Array
	Local cMsg          As Character
	Local cPropertie    As Character
	Local cField        As Character
	Local cCodigo       As Character
	Local cOper         As Character
	Local cCodUsr       As Character
	Local cNome         As Character
	Local cVend         As Character
	Local cEmail        As Character
	Local i             As Numeric
	Local x             As Numeric
	Local nPosxPyli     As Numeric
	Local aCabec        As Array
	Local aPropCab      As Array
	Local aIndexCabec   As Array
	Local oData         As Object
	Local uConteud

	PRIVATE lMsErroAuto    := .F.
	PRIVATE lMsHelpAuto     := .F.
	PRIVATE lAutoErrNoFile  := .T.

	DEFAULT nOper := 3
	DEFAULT cId := ""
	DEFAULT oBody := JsonObject():New()

	// Carrega config cTabelas do Portal
	cPrefDef := SuperGetMv("FS_TABWEB",.T.,"PW")

	cMsg 		:= ""
	cCodigo 	:= IIF(nOper==MODEL_OPERATION_INSERT,U_FGetCod("AOF",1,"AOF_CODIGO"),AOF->AOF_CODIGO)
	aIndexCabec := FieldPros(1)
	aCabec 		:= Array(0)
	aArea       := {}
	nPosxPyli 	:= 0
	cNome      	:= ""
	cCodUsr    	:= (cPrefDef+"0")->&(cPrefDef+"0_CODIGO")
	cEmail  	:= (cPrefDef+"0")->&(cPrefDef+"0_EMAIL")
	cVend       := ""

	dbSelectArea("AOF")
	dbSetOrder(1)

	If nOper <> MODEL_OPERATION_DELETE
		oData := oBody['data']
		aPropCab := oData:GetNames()
	Endif

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

		aAdd(aCabec,{"AOF_FILIAL" ,xFilial("AOF")    ,Nil})
		If !Empty(cCodigo)
			aAdd(aCabec,{"AOF_CODIGO" ,cCodigo           ,Nil})
		Endif

		// MONTAGEM DO ARRAY DE CABEÇALHO
		For i := 1 To Len(aPropCab)
			cPropertie := aPropCab[i]
			If ( x := aScan(aIndexCabec, {|x| x[1] == cPropertie}) ) > 0
				cField := aIndexCabec[x][2]
				If AOF->(FieldPos(cField)) > 0
					// Despresa Campos da PrimaryKey
					If cField $ "AOF_FILIAL|AOF_CODIGO"
						Loop
					EndIf

					uConteud := U_StruField("FORMAT", "AOF", cField, Nil, oData[cPropertie])

					aAdd(aCabec,{cField, uConteud, Nil})
				EndIf
			EndIf
		Next i

		If nOper == MODEL_OPERATION_UPDATE
			If (nPosxPyli := aScan(aCabec,{|x| Alltrim(x[1]) == "AOF_XPYLI"})) > 0
				If aCabec[nPosxPyli][2] <> "2"
					aCabec[nPosxPyli][2] := "2"
				EndIf
			Endif
		EndIf

		If nOper == MODEL_OPERATION_INSERT
			If !Empty(cEmail)
				SA3->(DbOrderNickName('FSEMAIL'))
				If SA3->(DbSeek(xFilial('SA3') + Lower(Alltrim(cEmail)))) .Or. SA3->(DbSeek(xFilial('SA3') + Upper(Alltrim(cEmail))))
					cVend := SA3->A3_COD
				EndIf
				If !Empty(cVend) .AND. AOF->(FieldPos("AOF_XVEND")) > 0
					aAdd(aCabec,{"AOF_XVEND",cVend,Nil})
				Endif
			EndIf
		Endif

		// ORDENAÇÃO DEFAULT(PW6) DOS CAMPOS
		U_FOrdData(@aCabec,,"AOF")

		If FindFunction("U_XCABCLI")
			aRetPee := U_XCABCLI(aCabec,nOper,"AOF")
			If ValType(aRetPee) == "A" .And. Len(aRetPee) >= 3
				aCabec  := aClone(aRetPee[1])
				cCodigo := aRetPee[2]
			EndIf
		EndIf

		// EXCLUSÃO
	ElseIf nOper == MODEL_OPERATION_DELETE

		// MONTAGEM DO ARRAY DE CABEÇALHO
		aAdd(aCabec, {"AOF_FILIAL", AOF->AOF_FILIAL,     Nil})
		aAdd(aCabec, {"AOF_CODIGO", cCodigo		   ,     Nil})

	EndIf

	BEGIN TRANSACTION

		lMsErroAuto := FSATIVIDADE(aCabec,nOper,cCodigo,cOper,@cMsg)

		If !lMsErroAuto
			// Chave Identificadora
			If nOper == MODEL_OPERATION_INSERT
				cId := AOF->&(IndexKey(1))
				cCodigo := AOF->AOF_CODIGO
			EndIf

			// Monta Mensagem padrão
			cMsg := cOper + " de ATIVIDADE incluida com sucesso!"
			If !Empty(cCodigo)
				cMsg += CRLF + "CÓDIGO: " + cCodigo
			Endif

			If nOper == MODEL_OPERATION_INSERT
				aArea := FwGetArea()
				cNome := NOMECRM()
				If !Empty(cNome) .and. AOF->(FieldPos("AOF_XVLEAD")) > 0
					RecLock("AOF",.F.)
					AOF->AOF_XVLEAD := cNome
					MsUnLock()
				Endif
				RestArea(aArea)
			ElseIf nOper == MODEL_OPERATION_UPDATE
				If findfunction("U_ExCrmPyl")
					U_ExCrmPyl(2)//proxima fase da atividade.
				EndIf
			EndIf
		Else
			If Empty(cMsg)
				cMsg := "Não foi possivel realizar a " + cOper + " da ATIVIDADE!"
			EndIf
		EndIf

		// Mensagem customizada
		If Type("cEthosxMsg") <> 'U' .And. !Empty(cEthosxMsg)
			cMsg := cEthosxMsg
		EndIf

	END TRANSACTION

Return {!lMsErroAuto,cMsg}


//-------------------------------------------------------------------
/*/{Protheus.doc} FSATIVIDADE

    Inclusão/Alteração/Exclusão de Atividades pelo portal.

@author Jose.Gavetti
@since 03/09/2024
@version 12
/*/
//-------------------------------------------------------------------
Static function FSATIVIDADE(aAtiv,nOper,cCodigo,cOper,cMsg)

	Local lOpc          As Logical
	Local lRet          As Logical
	Local _nX           As Numeric
	Local oModel 		As Object

	Default aAtiv 	:= {}
	Default nOper 	:= 0
	Default cCodigo := ""
	Default cOper   := ""

	lRet 	:= .F.
	lOpc 	:= .F.
	_nX  	:= 0
	oModel 	:= NIL

	If Alltrim(Str(nOper)) $ '4|5'
		AOF->(DbSeek(xFilial("AOF")+cCodigo))
	Endif

	oModel := FWLoadModel("CRMA180")
	oModel:SetOperation(nOper)
	oModel:Activate()
	If Alltrim(Str(nOper)) $ '3|4'
		For _nX := 1 To Len(aAtiv)
			oModel:SetValue( 'AOFMASTER' , aAtiv[_nX][1],  aAtiv[_nX][2])
		Next
		oModel:SetValue( 'AOFMASTER' , 'AOF_DTCAD'   ,  dDatabase)
		oModel:SetValue( 'AOFMASTER' , 'AOF_MSBLQL'  ,  "2"      )
	EndIf

	If oModel:VldData() .And. oModel:CommitData()
		ConOut(cOper + Time() )
	Else
		VarInfo("",oModel:GetErrorMessage())
		cMsg := oModel:GetErrorMessage()[6]
		lRet := .T.
	EndIf

Return lRet

// Função para pegar o nome do cliente.
Static Function NOMECRM()

	Local cNome := ""

	If AOF->AOF_ENTIDA == "ACH"
		cNome := POSICIONE("ACH",1,xFilial("ACH")+Alltrim(AOF->AOF_CHAVE),"ACH_RAZAO")
	elseif AOF->AOF_ENTIDA == "SUS"
		cNome := POSICIONE("SUS",1,xFilial("SUS")+Alltrim(AOF->AOF_CHAVE),"US_NOME")
	else
		cNome := POSICIONE("SA1",1,xFilial("SA1")+Alltrim(AOF->AOF_CHAVE),"A1_NOME")
	Endif

Return Alltrim(cNome)
