#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

#DEFINE WSCODE_OK    		200

#DEFINE TYPE_FORM_RETWS		"cp1252"


/*/{Protheus.doc} ZCrudSB1
    (long_description)
    @type  Function
    @author Cristian Gustavo
    @since 26/06/2025
    @version 
        1.0 Desenvolvimento inicial rotina
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
WSRESTFUL zCRUDSB1 DESCRIPTION "Web Service Rest Produtos(SB1)" FORMAT APPLICATION_JSON

	WSDATA B1_COD   AS CHARACTER OPTIONAL
	WSDATA nPageSize AS INTEGER OPTIONAL
	WSDATA nPage     AS INTEGER OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "Consulta tabela Produtos(SB1)";
		WSSYNTAX "/zCRUDSB1 || /'zCRUDSB1'/{B1_COD}" //Não possibilita utilizar outro GET

	WSMETHOD POST;
		DESCRIPTION "Inserção tabela Produtos(SB1) via MATA010";
		WSSYNTAX "" //Não possibilita utilizar outro GET

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
POST no modelo antigo WSSYNTAX que não valida agrupamentos e nem path

@author Cristian Gustavo
@since 05/09/2018
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE zCRUDSB1

	Local aResponse	 as Array
	Local jResponse  as Object
	Local oRequest   as Object
	Local oResponse  as Object
	Local lRetWS	 as Logical
	Local cMsgRet	 as Character

	Local oModel     as Object
	Local oSB1Mod    as Object

	aResponse   := {}
	jResponse   := JsonObject():New()
	oRequest    := JsonObject():New()
	oResponse   := JsonObject():New()

	lRetWS		:=	oRequest:FromJson(::GetContent()) // Self:GetContent() | Pega a string do JSON
	cMsgRet		:= ''

	oModel 		:= NIL
	oSB1Mod		:= NIL

	IF ValType(lRetWS) == 'U'
		//Pegando o modelo de dados, setando a operação de inclusão
		oModel := FWLoadModel("MATA010")
		oModel:SetOperation(3) //Inclusão
		oModel:Activate()

		//Pegando o model e setando os campos
		oSB1Mod := oModel:GetModel("SB1MASTER")
		oSB1Mod:SetValue("B1_COD",    AllTrim(oRequest['B1_COD']))
		oSB1Mod:SetValue("B1_DESC",   AllTrim(oRequest['B1_DESC']))
		oSB1Mod:SetValue("B1_TIPO",   AllTrim(oRequest['B1_TIPO']))
		oSB1Mod:SetValue("B1_UM",     AllTrim(oRequest['B1_UM']))
		oSB1Mod:SetValue("B1_LOCPAD", AllTrim(oRequest['B1_LOCPAD']))

		//Setando o complemento do produto
		oSB5Mod := oModel:GetModel("SB5DETAIL")
		If oSB5Mod != Nil
			oSB5Mod:SetValue("B5_CEME"   , AllTrim(oRequest['B5_CEME']))
		EndIf

		//Se conseguir validar as informações
		If oModel:VldData()
			//Tenta realizar o Commit
			If oModel:CommitData()
				lOk := .T.
			Else
				lOk := .F.
				cMsgRet += "Erro na inserção via CommitData, necessário verificar." + Chr(13) + Chr(10)
			EndIf
		Else //Se não conseguir validar as informações, altera a variável para false
			lOk := .F.
			cMsgRet += "Erro na validação das informações via CommitData, necessário verificar." + Chr(13) + Chr(10)
		EndIf

		//Se não deu certo a inclusão, mostra a mensagem de erro
		If !lOk
			aErro := oModel:GetErrorMessage() //Busca o Erro do Modelo de Dados

			/*cMsgRet := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
			cMsgRet += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
			cMsgRet += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
			cMsgRet += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
			cMsgRet += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
			cMsgRet += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
			cMsgRet += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
			cMsgRet += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'*/
			
			cMsgRet += "Mensagem do erro: " + AllTrim(cValToChar(aErro[06])) + Chr(13) + Chr(10)

			lRet := .F.
		Else
			lRet := .T.
		EndIf

		//Desativa o modelo de dados
		oModel:DeActivate()

		//Se não encontrar registros
		If lOk
			oResponse['mensage']	:= ENCODEUTF8(;
				'Registro: ' + AllTrim(oRequest['B1_COD']) + " - " + AllTrim(oRequest['B1_DESC']) + ;
				' inserido com sucesso!', TYPE_FORM_RETWS)
		Else	
			oResponse['mensage']	:= ENCODEUTF8(cMsgRet, TYPE_FORM_RETWS)
		EndIf
	Else
		oResponse['mensage']	:= ENCODEUTF8(;
			'Corpo da requisição fora do padrão JSON',;
			TYPE_FORM_RETWS)
	EndIf

	IF oResponse <> NIL
		Aadd(aResponse, oResponse)

		/*Liberação objetos JSON*/
		FreeObj(oResponse)
	ENDIF

	// define o tipo de retorno do método
	//::SetContentType("application/json")
	Self:SetContentType("application/json")
	//Self:SetResponse(jResponse:toJSON())
	Self:SetResponse(aResponse)
	Self:SetStatus(WSCODE_OK)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Get no modelo antigo WSSYNTAX que não valida agrupamentos e nem path

@author Cristian Gustavo
@since 05/09/2018
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE nPage, nPageSize WSSERVICE zCRUDSB1

	Local aResponse	 as Array
	Local nI         as Numeric
	Local nCount     as Numeric
	Local jResponse  as Object
	Local oResponse  as Object
	Local cAlias 	 as Character
	Local cWhere 	 as Character
	Local lRetWS	 as Logical

	Local nStart   	 as Numeric

	DEFAULT ::nPage := 1, ::nPageSize := 5

	aResponse   := {}
	nI          := 0
	nCount      := 0
	jResponse   := JsonObject():New()
	oResponse   := JsonObject():New()
	cAlias 		:= GetNextAlias()
	cWhere 		:= '%%'
	lRetWS		:= .T.
	nStart   	:= (::nPage - 1) * ::nPageSize

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/zCRUDSB1/1
	If Len(::aURLParms) > 0

		IF LEN(::aURLParms[1]) == 6 //Código de busca fixado tamanho 6
			cWhere := '%'
			cWhere += " AND B1_COD = '" + AllTrim(::aURLParms[1]) + "' " //Self:aURLParms[1]
			cWhere += '%'
		ELSE
			oResponse['mensage']	:= ENCODEUTF8(;
				'Código informado deve conter 6 caracteres.',;
				TYPE_FORM_RETWS)

			lRetWS := .F.
		ENDIF

	EndIf

	IF lRetWS

		BEGINSQL ALIAS cAlias

	SELECT	
        B1_FILIAL AS B1_FILIAL,
        B1_COD AS B1_COD,
        B1_DESC AS B1_DESC,
        B1_TIPO AS B1_TIPO,
		B1_UM AS B1_UM,
		B1_LOCPAD AS B1_LOCPAD,
		R_E_C_N_O_ AS R_E_C_N_O_
	FROM %Table:SB1% AS SB1
	WHERE SB1.%NotDel%
		%Exp:cWhere%
	ORDER BY B1_FILIAL, B1_COD 

		ENDSQL

		(cAlias)->(DbGoTop())

		// Pula registros até o início da página
		For nI := 1 To nStart
			If (cAlias)->(EoF())
				Exit
			EndIf
			(cAlias)->(DbSkip())
		Next

		//Se não encontrar registros
		If !(cAlias)->(EoF())
			While !( (cAlias)->(EoF()) ) .And. nCount < ::nPageSize
				oResponse := JsonObject():New()

				oResponse['B1_FILIAL'] := AllTrim((cAlias)->B1_FILIAL)
				oResponse['B1_COD'] := AllTrim((cAlias)->B1_COD)
				oResponse['B1_DESC'] := AllTrim((cAlias)->B1_DESC)
				oResponse['B1_TIPO'] := AllTrim((cAlias)->B1_TIPO)
				oResponse['B1_UM'] := AllTrim((cAlias)->B1_UM)
				oResponse['B1_LOCPAD'] := AllTrim((cAlias)->B1_LOCPAD)
				oResponse['R_E_C_N_O_'] := AllTrim((cAlias)->R_E_C_N_O_)

				Aadd(aResponse, oResponse)
				FreeObj(oResponse)

				nCount++
				(cAlias)->(DbSkip())
			End

			(cAlias)->(DbCloseArea())
		Else //Retorno vazio consulta SB1
			oResponse['mensage']	:= ENCODEUTF8(;
				'Não há retorno de registros da tabela de Produtos(SB1).',;
				TYPE_FORM_RETWS)
		EndIf

	ENDIF

	IF oResponse <> NIL
		Aadd(aResponse, oResponse)

		/*Liberação objetos JSON*/
		FreeObj(oResponse)
	ENDIF

	// define o tipo de retorno do método
	//::SetContentType("application/json")
	Self:SetContentType("application/json")
	//Self:SetResponse(jResponse:toJSON())
	Self:SetResponse(aResponse)
	Self:SetStatus(WSCODE_OK)

Return .T.
