#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

#DEFINE WSCODE_OK    			200

#DEFINE TYPE_FORM_RETWS			"cp1252"
#DEFINE MODEL_OPERATION_INSERT	3
#DEFINE MODEL_OPERATION_UPDATE	4
#DEFINE MODEL_OPERATION_DELETE	5

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

	WSDATA B1_COD    AS CHARACTER OPTIONAL
	WSDATA nPageSize AS INTEGER OPTIONAL
	WSDATA nPage     AS INTEGER OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "Consulta tabela Produtos(SB1)";
		WSSYNTAX "/zCRUDSB1 || /'zCRUDSB1'/{B1_COD}" //Não possibilita utilizar outro GET

	WSMETHOD POST;
		DESCRIPTION "Inserção tabela Produtos(SB1) via MATA010";
		WSSYNTAX "/zCRUDSB1"

	WSMETHOD PUT;
		DESCRIPTION "Alteração tabela Produtos(SB1) via MATA010";
		WSSYNTAX "/zCRUDSB1

	WSMETHOD DELETE;
		DESCRIPTION "Deleção tabela Produtos(SB1) via MATA010";
		WSSYNTAX "/zCRUDSB1 || /'zCRUDSB1'/{B1_COD}"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE
DELETE no modelo antigo WSSYNTAX que valida requisição via path

@author Cristian Gustavo
@since 26/07/2025
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE WSSERVICE zCRUDSB1

	Local aResponse	 as Array
	Local cCodSB1 	 as Character
	Local cMsgRet	 as Character

	Local jResponse  as Object
	Local oResponse  as Object
	Local oModel     as Object

	Local lRetWS	 as Logical
	Local lOk		 as Logical

	aResponse   := {}
	cCodSB1		:= ''
	cMsgRet 	:= ''

	jResponse   := JsonObject():New()
	oResponse   := JsonObject():New()
	oModel      := NIL

	lRetWS		:= .T.
	lOk			:= .T.

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/zCRUDSB1/000001
	If Len(::aURLParms) > 0

		IF LEN(::aURLParms[1]) == 6 //Código de busca fixado tamanho 6
			cCodSB1	:= AllTrim(::aURLParms[1])

			If !Empty(cCodSB1)
				DBSelectArea("SB1")
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek(xFilial("SB1") + cCodSB1))

					//Pegando o modelo de dados, setando a operação de inclusão
					oModel := FWLoadModel("MATA010")
					oModel:SetOperation(MODEL_OPERATION_DELETE) //Exclusão
					oModel:Activate()

					//Se conseguir validar as informações
					If oModel:VldData()
						//Tenta realizar o Commit
						If oModel:CommitData()
							lOk := .T.
						Else
							lOk := .F.
							cMsgRet += "Erro na exclusão via CommitData, necessário verificar." + Chr(13) + Chr(10)
						EndIf
					Else //Se não conseguir validar as informações, altera a variável para false
						lOk := .F.
						cMsgRet += "Erro na validação das informações via CommitData, necessário verificar." + Chr(13) + 	Chr(10)
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
					Endif
				Else
        		    lOk := .F.
        		    cMsgRet += "Produto não encontrado para exclusão." + Chr(13) + Chr(10)
        		EndIf
			Else
        		lOk := .F.
				cMsgRet	:= 'Campo: B1_COD' + ' não informado no endereço da requisição!'
			EndIf

			//Desativa o modelo de dados
			If oModel <> Nil
    			oModel:DeActivate()
			EndIf

		Else
			lOk := .F.
			cMsgRet	:= 'Código informado deve conter 6 caracteres.'
		EndIf

	Else
    	lOk := .F.
		cMsgRet	:= 'Campo: B1_COD' + ' não informado no endereço da requisição!'
	EndIf

	//Se não encontrar registros
	If lOk
		oResponse['mensage']	:= ENCODEUTF8(;
		'Registro: ' + cCodSB1 + ' excluido com sucesso!', TYPE_FORM_RETWS)
	Else	
		oResponse['mensage']	:= ENCODEUTF8(cMsgRet, TYPE_FORM_RETWS)
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
/*/{Protheus.doc} PUT
PUT no modelo antigo WSSYNTAX que valida corpo da requisição via JSON

@author Cristian Gustavo
@since 26/07/2025
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSSERVICE zCRUDSB1

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

		If !Empty(AllTrim(oRequest['B1_COD']))
			DBSelectArea("SB1")
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1") + AllTrim(oRequest['B1_COD'])))

				//Pegando o modelo de dados, setando a operação de inclusão
				oModel := FWLoadModel("MATA010")
				oModel:SetOperation(MODEL_OPERATION_UPDATE) //Alteração
				oModel:Activate()

				//Pegando o model e setando os campos
				oSB1Mod := oModel:GetModel("SB1MASTER")
				oSB1Mod:SetValue("B1_DESC",   AllTrim(oRequest['B1_DESC']))
				oSB1Mod:SetValue("B1_TIPO",   AllTrim(oRequest['B1_TIPO']))
				oSB1Mod:SetValue("B1_UM",     AllTrim(oRequest['B1_UM']))
				oSB1Mod:SetValue("B1_LOCPAD", AllTrim(oRequest['B1_LOCPAD']))

				If !Empty(AllTrim(oRequest['B5_CEME']))
					DBSelectArea("SB5")
					SB5->(DbSetOrder(1))
					If SB5->(DbSeek(xFilial("SB5") + AllTrim(oRequest['B1_COD'])))
						oSB5Mod := oModel:GetModel("SB5DETAIL")
						If oSB5Mod != Nil
							oSB5Mod:SetValue("B5_CEME", AllTrim(oRequest['B5_CEME']))
						EndIf
					EndIf
				EndIf

				//Se conseguir validar as informações
				If oModel:VldData()
					//Tenta realizar o Commit
					If oModel:CommitData()
						lOk := .T.
					Else
						lOk := .F.
						cMsgRet += "Erro na alteração via CommitData, necessário verificar." + Chr(13) + Chr(10)
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
					Endif
			Else
        	    lOk := .F.
        	    cMsgRet += "Produto não encontrado para alteração." + Chr(13) + Chr(10)
        	EndIf
		Else
        	lOk := .F.
			cMsgRet	:= 'Campo: B1_COD' + ' não informado no corpo da requisição!'
		EndIf

		//Desativa o modelo de dados
		If oModel <> Nil
    		oModel:DeActivate()
		EndIf

		//Se não encontrar registros
		If lOk
			oResponse['mensage']	:= ENCODEUTF8(;
				'Registro: ' + AllTrim(oRequest['B1_COD']) + " - " + AllTrim(oRequest['B1_DESC']) + ;
				' alterado com sucesso!', TYPE_FORM_RETWS)
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
POST no modelo antigo WSSYNTAX que valida corpo da requisição via JSON

@author Cristian Gustavo
@since 26/07/2025
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE zCRUDSB1

	Local aResponse	 as Array
	Local cMsgRet	 as Character

	Local jResponse  as Object
	Local oRequest   as Object
	Local oResponse  as Object

	Local lRetWS	 as Logical

	Local oModel     as Object
	Local oSB1Mod    as Object

	aResponse   := {}
	cMsgRet		:= ''

	jResponse   := JsonObject():New()
	oRequest    := JsonObject():New()
	oResponse   := JsonObject():New()

	lRetWS		:=	oRequest:FromJson(::GetContent()) // Self:GetContent() | Pega a string do JSON

	oModel 		:= NIL
	oSB1Mod		:= NIL

	IF ValType(lRetWS) == 'U'
		//Pegando o modelo de dados, setando a operação de inclusão
		oModel := FWLoadModel("MATA010")
		oModel:SetOperation(MODEL_OPERATION_INSERT) //Inclusão
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
		If oModel <> Nil
    		oModel:DeActivate()
		EndIf

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
/*/{Protheus.doc} GET
Get no modelo antigo WSSYNTAX que valida agrupamentos e path

@author Cristian Gustavo
@since 26/07/2025
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE nPage, nPageSize WSSERVICE zCRUDSB1

	Local aResponse	 as Array
	Local lRetWS	 as Logical

	Local nI         as Numeric
	Local nCount     as Numeric
	Local nStart   	 as Numeric

	Local jResponse  as Object
	Local oResponse  as Object

	Local cAlias 	 as Character
	Local cWhere 	 as Character

	DEFAULT ::nPage := 1, ::nPageSize := 5

	aResponse   := {}
	lRetWS		:= .T.

	nI          := 0
	nCount      := 0

	jResponse   := JsonObject():New()
	oResponse   := JsonObject():New()

	cAlias 		:= GetNextAlias()
	cWhere 		:= '%%'

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
				oResponse['R_E_C_N_O_'] := (cAlias)->R_E_C_N_O_

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
