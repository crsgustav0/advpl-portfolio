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

/*/{Protheus.doc} ZCrudSA1
    (long_description)
    @type  Function
    @author Cristian Gustavo
    @since 05/07/2025
    @version 
        1.0 Desenvolvimento inicial rotina
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
WSRESTFUL zCRUDSA1 DESCRIPTION "Web Service Rest Clientes(SA1)" FORMAT APPLICATION_JSON

	WSDATA A1_COD    AS CHARACTER OPTIONAL
	WSDATA nPageSize AS INTEGER OPTIONAL
	WSDATA nPage     AS INTEGER OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "Consulta tabela Clientes(SA1)";
		WSSYNTAX "/zCRUDSA1 || /'zCRUDSA1'/{A1_COD}" //N�o possibilita utilizar outro GET

	WSMETHOD POST;
		DESCRIPTION "Inser��o tabela Clientes(SA1) via MATA030";
		WSSYNTAX "/zCRUDSA1"

	WSMETHOD PUT;
		DESCRIPTION "Altera��o tabela Clientes(SA1) via MATA030";
		WSSYNTAX "/zCRUDSA1

	WSMETHOD DELETE;
		DESCRIPTION "Dele��o tabela Clientes(SA1) via MATA030";
		WSSYNTAX "/zCRUDSA1 || /'zCRUDSA1'/{A1_COD}"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE
DELETE no modelo antigo WSSYNTAX que valida requisi��o via path

@author Cristian Gustavo
@since 02/08/2025
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE WSSERVICE zCRUDSA1

	Local aResponse	 as Array
	Local cCodSA1 	 as Character
	Local cMsgRet	 as Character

	Local jResponse  as Object
	Local oResponse  as Object
	Local oModel     as Object

	Local lRetWS	 as Logical
	Local lOk		 as Logical

	aResponse   := {}
	cCodSA1		:= ''
	cMsgRet 	:= ''

	jResponse   := JsonObject():New()
	oResponse   := JsonObject():New()
	oModel      := NIL

	lRetWS		:= .T.
	lOk			:= .T.

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/zCRUDSA1/000001
	If Len(::aURLParms) > 0

		IF LEN(::aURLParms[1]) == 6 //C�digo de busca fixado tamanho 6
			cCodSA1	:= AllTrim(::aURLParms[1])

			If !Empty(cCodSA1)
				DBSelectArea("SA1")
				SA1->(DbSetOrder(1))
				If SA1->(DbSeek(xFilial("SA1") + cCodSA1))

					//Pegando o modelo de dados, setando a opera��o de inclus�o
					oModel := FWLoadModel("CRMA980")
					oModel:SetOperation(MODEL_OPERATION_DELETE) //Exclus�o
					oModel:Activate()

					//Se conseguir validar as informa��es
					If oModel:VldData()
						//Tenta realizar o Commit
						If oModel:CommitData()
							lOk := .T.
						Else
							lOk := .F.
							cMsgRet += "Erro na exclus�o via CommitData, necess�rio verificar." + Chr(13) + Chr(10)
						EndIf
					Else //Se n�o conseguir validar as informa��es, altera a vari�vel para false
						lOk := .F.
						cMsgRet += "Erro na valida��o das informa��es via CommitData, necess�rio verificar." + Chr(13) + 	Chr(10)
					EndIf

					//Se n�o deu certo a inclus�o, mostra a mensagem de erro
					If !lOk
						aErro := oModel:GetErrorMessage() //Busca o Erro do Modelo de Dados
						/*cMsgRet := "Id do formul�rio de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
						cMsgRet += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
						cMsgRet += "Id do formul�rio de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
						cMsgRet += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
						cMsgRet += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
						cMsgRet += "Mensagem da solu��o: "        + ' [' + cValToChar(aErro[07]) + '], '
						cMsgRet += "Valor atribu�do: "            + ' [' + cValToChar(aErro[08]) + '], '
						cMsgRet += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'*/

						cMsgRet += "Mensagem do erro: " + AllTrim(cValToChar(aErro[06])) + Chr(13) + Chr(10)
						lRet := .F.
					Endif
				Else
        		    lOk := .F.
        		    cMsgRet += "Cliente n�o encontrado para exclus�o." + Chr(13) + Chr(10)
        		EndIf
			Else
        		lOk := .F.
				cMsgRet	:= 'Campo: A1_COD' + ' n�o informado no endere�o da requisi��o!'
			EndIf

			//Desativa o modelo de dados
			If oModel <> Nil
    			oModel:DeActivate()
			EndIf

		Else
			lOk := .F.
			cMsgRet	:= 'C�digo informado deve conter 6 caracteres.'
		EndIf

	Else
    	lOk := .F.
		cMsgRet	:= 'Campo: A1_COD' + ' n�o informado no endere�o da requisi��o!'
	EndIf

	//Se n�o encontrar registros
	If lOk
		oResponse['mensage']	:= ENCODEUTF8(;
		'Registro: ' + cCodSA1 + ' excluido com sucesso!', TYPE_FORM_RETWS)
	Else	
		oResponse['mensage']	:= ENCODEUTF8(cMsgRet, TYPE_FORM_RETWS)
	EndIf

	IF oResponse <> NIL
		Aadd(aResponse, oResponse)

		/*Libera��o objetos JSON*/
		FreeObj(oResponse)
	ENDIF
	
	// define o tipo de retorno do m�todo
	//::SetContentType("application/json")
	Self:SetContentType("application/json")
	//Self:SetResponse(jResponse:toJSON())
	Self:SetResponse(aResponse)
	Self:SetStatus(WSCODE_OK)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT
PUT no modelo antigo WSSYNTAX que valida corpo da requisi��o via JSON

@author Cristian Gustavo
@since 02/08/2025
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSSERVICE zCRUDSA1

	Local aResponse	 as Array
	Local jResponse  as Object
	Local oRequest   as Object
	Local oResponse  as Object
	Local lRetWS	 as Logical
	Local cMsgRet	 as Character

	Local oModel     as Object
	Local oSA1Mod    as Object

	aResponse   := {}
	jResponse   := JsonObject():New()
	oRequest    := JsonObject():New()
	oResponse   := JsonObject():New()

	lRetWS		:=	oRequest:FromJson(::GetContent()) // Self:GetContent() | Pega a string do JSON
	cMsgRet		:= ''

	oModel 		:= NIL
	oSA1Mod		:= NIL

	IF ValType(lRetWS) == 'U'

		If !Empty(AllTrim(oRequest['A1_COD']))
			DBSelectArea("SA1")
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1") + AllTrim(oRequest['A1_COD'])))

				//Pegando o modelo de dados, setando a opera��o de inclus�o
				oModel := FWLoadModel("CRMA980")
				oModel:SetOperation(MODEL_OPERATION_UPDATE) //Altera��o
				oModel:Activate()

				//Pegando o model e setando os campos
				oSA1Mod := oModel:GetModel("SA1MASTER")
				oSA1Mod:SetValue("A1_NOME",   AllTrim(oRequest['A1_NOME']))
				oSA1Mod:SetValue("A1_NREDUZ",   AllTrim(oRequest['A1_NREDUZ']))
				oSA1Mod:SetValue("A1_END",   AllTrim(oRequest['A1_END']))
				oSA1Mod:SetValue("A1_TIPO",   AllTrim(oRequest['A1_TIPO']))
				oSA1Mod:SetValue("A1_EST",   AllTrim(oRequest['A1_EST']))
				oSA1Mod:SetValue("A1_MUN",   AllTrim(oRequest['A1_MUN']))
				
				//Se conseguir validar as informa��es
				If oModel:VldData()
					//Tenta realizar o Commit
					If oModel:CommitData()
						lOk := .T.
					Else
						lOk := .F.
						cMsgRet += "Erro na altera��o via CommitData, necess�rio verificar." + Chr(13) + Chr(10)
					EndIf
				Else //Se n�o conseguir validar as informa��es, altera a vari�vel para false
					lOk := .F.
					cMsgRet += "Erro na valida��o das informa��es via CommitData, necess�rio verificar." + Chr(13) + Chr(10)
				EndIf

				//Se n�o deu certo a inclus�o, mostra a mensagem de erro
				If !lOk
					aErro := oModel:GetErrorMessage() //Busca o Erro do Modelo de Dados

					/*cMsgRet := "Id do formul�rio de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
					cMsgRet += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
					cMsgRet += "Id do formul�rio de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
					cMsgRet += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
					cMsgRet += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
					cMsgRet += "Mensagem da solu��o: "        + ' [' + cValToChar(aErro[07]) + '], '
					cMsgRet += "Valor atribu�do: "            + ' [' + cValToChar(aErro[08]) + '], '
					cMsgRet += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'*/

					cMsgRet += "Mensagem do erro: " + AllTrim(cValToChar(aErro[06])) + Chr(13) + Chr(10)

					lRet := .F.
					Endif
			Else
        	    lOk := .F.
        	    cMsgRet += "Cliente n�o encontrado para altera��o." + Chr(13) + Chr(10)
        	EndIf
		Else
        	lOk := .F.
			cMsgRet	:= 'Campo: A1_COD' + ' n�o informado no corpo da requisi��o!'
		EndIf

		//Desativa o modelo de dados
		If oModel <> Nil
    		oModel:DeActivate()
		EndIf

		//Se n�o encontrar registros
		If lOk
			oResponse['mensage']	:= ENCODEUTF8(;
				'Registro: ' + AllTrim(oRequest['A1_COD']) + " - " + AllTrim(oRequest['A1_NOME']) + ;
				' alterado com sucesso!', TYPE_FORM_RETWS)
		Else	
			oResponse['mensage']	:= ENCODEUTF8(cMsgRet, TYPE_FORM_RETWS)
		EndIf
	Else
		oResponse['mensage']	:= ENCODEUTF8(;
			'Corpo da requisi��o fora do padr�o JSON',;
			TYPE_FORM_RETWS)
	EndIf

	IF oResponse <> NIL
		Aadd(aResponse, oResponse)

		/*Libera��o objetos JSON*/
		FreeObj(oResponse)
	ENDIF

	// define o tipo de retorno do m�todo
	//::SetContentType("application/json")
	Self:SetContentType("application/json")
	//Self:SetResponse(jResponse:toJSON())
	Self:SetResponse(aResponse)
	Self:SetStatus(WSCODE_OK)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
POST no modelo antigo WSSYNTAX que valida corpo da requisi��o via JSON

@author Cristian Gustavo
@since 02/08/2025
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE zCRUDSA1

	Local aResponse	 as Array
	Local cMsgRet	 as Character

	Local jResponse  as Object
	Local oRequest   as Object
	Local oResponse  as Object

	Local lRetWS	 as Logical

	Local oModel     as Object
	Local oSA1Mod    as Object

	aResponse   := {}
	cMsgRet		:= ''

	jResponse   := JsonObject():New()
	oRequest    := JsonObject():New()
	oResponse   := JsonObject():New()

	lRetWS		:=	oRequest:FromJson(::GetContent()) // Self:GetContent() | Pega a string do JSON

	oModel 		:= NIL
	oSA1Mod		:= NIL

	IF ValType(lRetWS) == 'U'
		//Pegando o modelo de dados, setando a opera��o de inclus�o
		oModel := FWLoadModel("CRMA980")
		oModel:SetOperation(MODEL_OPERATION_INSERT) //Inclus�o
		oModel:Activate()

		//Pegando o model e setando os campos
		oSA1Mod := oModel:GetModel("SA1MASTER")
		oSA1Mod:SetValue("A1_COD",    AllTrim(oRequest['A1_COD']))
		oSA1Mod:SetValue("A1_NOME",   AllTrim(oRequest['A1_NOME']))
		oSA1Mod:SetValue("A1_LOJA",   AllTrim(oRequest['A1_LOJA']))
		oSA1Mod:SetValue("A1_NREDUZ", AllTrim(oRequest['A1_NREDUZ']))
		oSA1Mod:SetValue("A1_END",    AllTrim(oRequest['A1_END']))
		oSA1Mod:SetValue("A1_TIPO",   AllTrim(oRequest['A1_TIPO']))
		oSA1Mod:SetValue("A1_EST",    AllTrim(oRequest['A1_EST']))
		oSA1Mod:SetValue("A1_MUN",    AllTrim(oRequest['A1_MUN']))

		//Se conseguir validar as informa��es
		If oModel:VldData()
			//Tenta realizar o Commit
			If oModel:CommitData()
				lOk := .T.
			Else
				lOk := .F.
				cMsgRet += "Erro na inser��o via CommitData, necess�rio verificar." + Chr(13) + Chr(10)
			EndIf
		Else //Se n�o conseguir validar as informa��es, altera a vari�vel para false
			lOk := .F.
			cMsgRet += "Erro na valida��o das informa��es via CommitData, necess�rio verificar." + Chr(13) + Chr(10)
		EndIf

		//Se n�o deu certo a inclus�o, mostra a mensagem de erro
		If !lOk
			aErro := oModel:GetErrorMessage() //Busca o Erro do Modelo de Dados

			/*cMsgRet := "Id do formul�rio de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
			cMsgRet += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
			cMsgRet += "Id do formul�rio de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
			cMsgRet += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
			cMsgRet += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
			cMsgRet += "Mensagem da solu��o: "        + ' [' + cValToChar(aErro[07]) + '], '
			cMsgRet += "Valor atribu�do: "            + ' [' + cValToChar(aErro[08]) + '], '
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

		//Se n�o encontrar registros
		If lOk
			oResponse['mensage']	:= ENCODEUTF8(;
				'Registro: ' + AllTrim(oRequest['A1_COD']) + " - " + AllTrim(oRequest['A1_NOME']) + ;
				' inserido com sucesso!', TYPE_FORM_RETWS)
		Else	
			oResponse['mensage']	:= ENCODEUTF8(cMsgRet, TYPE_FORM_RETWS)
		EndIf
	Else
		oResponse['mensage']	:= ENCODEUTF8(;
			'Corpo da requisi��o fora do padr�o JSON',;
			TYPE_FORM_RETWS)
	EndIf

	IF oResponse <> NIL
		Aadd(aResponse, oResponse)

		/*Libera��o objetos JSON*/
		FreeObj(oResponse)
	ENDIF

	// define o tipo de retorno do m�todo
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
@since 02/08/2025
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE nPage, nPageSize WSSERVICE zCRUDSA1

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
	// exemplo: http://localhost:8080/zCRUDSA1/1
	If Len(::aURLParms) > 0

		IF LEN(::aURLParms[1]) == 6 //C�digo de busca fixado tamanho 6
			cWhere := '%'
			cWhere += " AND A1_COD = '" + AllTrim(::aURLParms[1]) + "' " //Self:aURLParms[1]
			cWhere += '%'
		ELSE
			oResponse['mensage']	:= ENCODEUTF8(;
				'C�digo informado deve conter 6 caracteres.',;
				TYPE_FORM_RETWS)

			lRetWS := .F.
		ENDIF

	EndIf

	IF lRetWS

		BEGINSQL ALIAS cAlias

	SELECT	
        A1_COD AS A1_COD,
		A1_LOJA AS A1_LOJA,
		A1_NREDUZ AS A1_NREDUZ,
		A1_END AS A1_END,
		A1_TIPO AS A1_TIPO,
		A1_EST AS A1_EST,
		A1_MUN AS A1_MUN,
		R_E_C_N_O_ AS R_E_C_N_O_
	FROM %Table:SA1% AS SA1
	WHERE SA1.%NotDel%
		%Exp:cWhere%
	ORDER BY A1_FILIAL, A1_COD, A1_LOJA, A1_NOME

		ENDSQL

		(cAlias)->(DbGoTop())

		// Pula registros at� o in�cio da p�gina
		For nI := 1 To nStart
			If (cAlias)->(EoF())
				Exit
			EndIf
			(cAlias)->(DbSkip())
		Next

		//Se n�o encontrar registros
		If !(cAlias)->(EoF())
			While !( (cAlias)->(EoF()) ) .And. nCount < ::nPageSize
				oResponse := JsonObject():New()

				oResponse['A1_COD'] := AllTrim((cAlias)->A1_COD)
				oResponse['A1_LOJA'] := AllTrim((cAlias)->A1_LOJA)
				oResponse['A1_NREDUZ'] := AllTrim((cAlias)->A1_NREDUZ)
				oResponse['A1_END'] := AllTrim((cAlias)->A1_END)
				oResponse['A1_TIPO'] := AllTrim((cAlias)->A1_TIPO)
				oResponse['A1_EST'] := AllTrim((cAlias)->A1_EST)
				oResponse['A1_MUN'] := AllTrim((cAlias)->A1_MUN)
				oResponse['R_E_C_N_O_'] := (cAlias)->R_E_C_N_O_

				Aadd(aResponse, oResponse)
				FreeObj(oResponse)

				nCount++
				(cAlias)->(DbSkip())
			End

			(cAlias)->(DbCloseArea())
		Else //Retorno vazio consulta SA1
			oResponse['mensage']	:= ENCODEUTF8(;
				'N�o h� retorno de registros da tabela de Clientes(SA1).',;
				TYPE_FORM_RETWS)
		EndIf

	ENDIF

	IF oResponse <> NIL
		Aadd(aResponse, oResponse)

		/*Libera��o objetos JSON*/
		FreeObj(oResponse)
	ENDIF

	// define o tipo de retorno do m�todo
	//::SetContentType("application/json")
	Self:SetContentType("application/json")
	//Self:SetResponse(jResponse:toJSON())
	Self:SetResponse(aResponse)
	Self:SetStatus(WSCODE_OK)

Return .T.
