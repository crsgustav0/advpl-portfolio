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

/*/{Protheus.doc} ZCrudSA2
    (long_description)
    @type  Function
    @author Cristian Gustavo
    @since 06/07/2025
    @version 
        1.0 Desenvolvimento inicial rotina
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
WSRESTFUL zCRUDSA2 DESCRIPTION "Web Service Rest Fornecedores(SA2)" FORMAT APPLICATION_JSON

	WSDATA A2_COD    AS CHARACTER OPTIONAL
	WSDATA nPageSize AS INTEGER OPTIONAL
	WSDATA nPage     AS INTEGER OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "Consulta tabela Fornecedores(SA2)";
		WSSYNTAX "/zCRUDSA2 || /'zCRUDSA2'/{A2_COD}" //N�o possibilita utilizar outro GET

	WSMETHOD POST;
		DESCRIPTION "Inser��o tabela Fornecedores(SA2) via MATA020";
		WSSYNTAX "/zCRUDSA2"

	WSMETHOD PUT;
		DESCRIPTION "Altera��o tabela Fornecedores(SA2) via MATA020";
		WSSYNTAX "/zCRUDSA2

	WSMETHOD DELETE;
		DESCRIPTION "Dele��o tabela Fornecedores(SA2) via MATA020";
		WSSYNTAX "/zCRUDSA2 || /'zCRUDSA2'/{A2_COD}"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE
DELETE no modelo antigo WSSYNTAX que valida requisi��o via path

@author Cristian Gustavo
@since 02/08/2025
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE WSSERVICE zCRUDSA2

	Local aResponse	 as Array
	Local cCodSA2 	 as Character
	Local cMsgRet	 as Character

	Local jResponse  as Object
	Local oResponse  as Object
	Local oModel     as Object

	Local lRetWS	 as Logical
	Local lOk		 as Logical

	aResponse   := {}
	cCodSA2		:= ''
	cMsgRet 	:= ''

	jResponse   := JsonObject():New()
	oResponse   := JsonObject():New()
	oModel      := NIL

	lRetWS		:= .T.
	lOk			:= .T.

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/zCRUDSA2/000001
	If Len(::aURLParms) > 0

		IF LEN(::aURLParms[1]) == 6 //C�digo de busca fixado tamanho 6
			cCodSA2	:= AllTrim(::aURLParms[1])

			If !Empty(cCodSA2)
				DBSelectArea("SA2")
				SA2->(DbSetOrder(1))
				If SA2->(DbSeek(xFilial("SA2") + cCodSA2))

					//Pegando o modelo de dados, setando a opera��o de inclus�o
					oModel := FWLoadModel("MATA020M")
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
        		    cMsgRet += "Fornecedor n�o encontrado para exclus�o." + Chr(13) + Chr(10)
        		EndIf
			Else
        		lOk := .F.
				cMsgRet	:= 'Campo: A2_COD' + ' n�o informado no endere�o da requisi��o!'
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
		cMsgRet	:= 'Campo: A2_COD' + ' n�o informado no endere�o da requisi��o!'
	EndIf

	//Se n�o encontrar registros
	If lOk
		oResponse['mensage']	:= ENCODEUTF8(;
		'Registro: ' + cCodSA2 + ' excluido com sucesso!', TYPE_FORM_RETWS)
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
WSMETHOD PUT WSSERVICE zCRUDSA2

	Local aResponse	 as Array
	Local jResponse  as Object
	Local oRequest   as Object
	Local oResponse  as Object
	Local lRetWS	 as Logical
	Local cMsgRet	 as Character

	Local oModel     as Object
	Local oSA2Mod    as Object

	aResponse   := {}
	jResponse   := JsonObject():New()
	oRequest    := JsonObject():New()
	oResponse   := JsonObject():New()

	lRetWS		:=	oRequest:FromJson(::GetContent()) // Self:GetContent() | Pega a string do JSON
	cMsgRet		:= ''

	oModel 		:= NIL
	oSA2Mod		:= NIL

	IF ValType(lRetWS) == 'U'

		If !Empty(AllTrim(oRequest['A2_COD']))
			DBSelectArea("SA2")
			SA2->(DbSetOrder(1))
			If SA2->(DbSeek(xFilial("SA2") + AllTrim(oRequest['A2_COD'])))

				//Pegando o modelo de dados, setando a opera��o de inclus�o
				oModel := FWLoadModel("MATA020M")
				oModel:SetOperation(MODEL_OPERATION_UPDATE) //Altera��o
				oModel:Activate()

				//Pegando o model e setando os campos
				oSA2Mod := oModel:GetModel("SA2MASTER")
				oSA2Mod:SetValue("A2_NOME",   AllTrim(oRequest['A2_NOME']))
				oSA2Mod:SetValue("A2_NREDUZ", AllTrim(oRequest['A2_NOME']))
				oSA2Mod:SetValue("A2_TIPO",   AllTrim(oRequest['A2_TIPO']))
				oSA2Mod:SetValue("A2_END",   AllTrim(oRequest['A2_END']))

				//1 CC2_FILIAL,CC2_EST,CC2_CODMUN
				//2 CC2_FILIAL,CC2_MUN
				//3 CC2_FILIAL,CC2_CODMUN

				//No preenchimento do c�digo mun. e estada, faz o preenchimento do campo "CC2_MUN"
				IF !Empty(AllTrim(oRequest['A2_COD_MUN'])) .AND. !Empty(AllTrim(oRequest['A2_ESTADO']))
					cCodEst  := AllTrim(oRequest['A2_ESTADO'])

					cCodMun  := Posicione("CC2", 1, XFILIAL("CC2") + cCodEst + AllTrim(oRequest['A2_COD_MUN']), "CC2_CODMUN") //Cod. Municipio
					cDescEst := AllTrim(Posicione('CC2', 1, XFILIAL("CC2") + cCodEst + cCodMun, 'CC2_EST')) //Estado
					cDescMun := Posicione('CC2', 1, XFILIAL("CC2") + cCodEst + cCodMun, 'CC2_MUN') //Municipio

				//Caso somente o c�digo seja preenchido, faz o preenchimento dos campos "A2_ESTADO" e "A2_MUN"
				ElseIF !Empty(AllTrim(oRequest['A2_COD_MUN'])) .AND. Empty(AllTrim(oRequest['A2_ESTADO']))
					cCodMun  := AllTrim(oRequest['A2_COD_MUN'])

					cDescEst := AllTrim(Posicione('CC2', 3, XFILIAL("CC2") + cCodMun, 'CC2_EST')) //	Estado
					cDescMun := AllTrim(Posicione('CC2', 3, XFILIAL("CC2") + cCodMun, 'CC2_MUN')) //	Municipio
				Else
					cCodMun  := ''
					cDescEst := ''
					cDescMun := ''
				ENDIF

				oSA2Mod:SetValue("A2_ESTADO",  cDescEst)
				oSA2Mod:SetValue("A2_EST",     cDescEst)
				oSA2Mod:SetValue("A2_COD_MUN", cCodMun)
				oSA2Mod:SetValue("A2_MUN",     cDescMun)
				
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
        	    cMsgRet += "Fornecedor n�o encontrado para altera��o." + Chr(13) + Chr(10)
        	EndIf
		Else
        	lOk := .F.
			cMsgRet	:= 'Campo: A2_COD' + ' n�o informado no corpo da requisi��o!'
		EndIf

		//Desativa o modelo de dados
		If oModel <> Nil
    		oModel:DeActivate()
		EndIf

		//Se n�o encontrar registros
		If lOk
			oResponse['mensage']	:= ENCODEUTF8(;
				'Registro: ' + AllTrim(oRequest['A2_COD']) + " - " + AllTrim(oRequest['A2_NOME']) + ;
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
WSMETHOD POST WSSERVICE zCRUDSA2

	Local aResponse	 as Array
	Local cMsgRet	 as Character

	Local cCodMun	 as Character	
	Local cCodEst	 as Character	
	Local cDescMun	 as Character	
	Local cDescEst	 as Character	

	Local jResponse  as Object
	Local oRequest   as Object 
	Local oResponse  as Object

	Local lRetWS	 as Logical

	Local oModel     as Object
	Local oSA2Mod    as Object

	aResponse   := {}
	cMsgRet		:= ''

	cCodMun		:= ''
	cCodEst		:= ''
	cDescMun	:= ''
	cDescEst	:= ''

	jResponse   := JsonObject():New()
	oRequest    := JsonObject():New()
	oResponse   := JsonObject():New()

	lRetWS		:=	oRequest:FromJson(::GetContent()) // Self:GetContent() | Pega a string do JSON

	oModel 		:= NIL
	oSA2Mod		:= NIL

	IF ValType(lRetWS) == 'U'
		//Pegando o modelo de dados, setando a opera��o de inclus�o
		oModel := FWLoadModel("MATA020M")
		oModel:SetOperation(MODEL_OPERATION_INSERT) //Inclus�o
		oModel:Activate()

		//Pegando o model e setando os campos
		oSA2Mod := oModel:GetModel("SA2MASTER")
		oSA2Mod:SetValue("A2_COD",    AllTrim(oRequest['A2_COD']))
		oSA2Mod:SetValue("A2_NOME",   AllTrim(oRequest['A2_NOME']))
		oSA2Mod:SetValue("A2_NREDUZ", AllTrim(oRequest['A2_NOME']))
		oSA2Mod:SetValue("A2_LOJA",   AllTrim(oRequest['A2_LOJA']))
		oSA2Mod:SetValue("A2_TIPO",   AllTrim(oRequest['A2_TIPO']))
		oSA2Mod:SetValue("A2_END",   AllTrim(oRequest['A2_END']))

		//1 CC2_FILIAL,CC2_EST,CC2_CODMUN
		//2 CC2_FILIAL,CC2_MUN
		//3 CC2_FILIAL,CC2_CODMUN
		
		//No preenchimento do c�digo mun. e estada, faz o preenchimento do campo "CC2_MUN"
		IF !Empty(AllTrim(oRequest['A2_COD_MUN'])) .AND. !Empty(AllTrim(oRequest['A2_ESTADO']))
			cCodEst  := AllTrim(oRequest['A2_ESTADO'])

			cCodMun  := Posicione("CC2", 1, XFILIAL("CC2") + cCodEst + AllTrim(oRequest['A2_COD_MUN']), "CC2_CODMUN") //Cod. Municipio
			cDescEst := AllTrim(Posicione('CC2', 1, XFILIAL("CC2") + cCodEst + cCodMun, 'CC2_EST')) //Estado
			cDescMun := Posicione('CC2', 1, XFILIAL("CC2") + cCodEst + cCodMun, 'CC2_MUN') //Municipio

		//Caso somente o c�digo seja preenchido, faz o preenchimento dos campos "A2_ESTADO" e "A2_MUN"
		ElseIF !Empty(AllTrim(oRequest['A2_COD_MUN'])) .AND. Empty(AllTrim(oRequest['A2_ESTADO']))
			cCodMun  := AllTrim(oRequest['A2_COD_MUN'])

			cDescEst := AllTrim(Posicione('CC2', 3, XFILIAL("CC2") + cCodMun, 'CC2_EST')) //Estado
			cDescMun := AllTrim(Posicione('CC2', 3, XFILIAL("CC2") + cCodMun, 'CC2_MUN')) //Municipio
		Else
			cCodMun  := ''
			cDescEst := ''
			cDescMun := ''
		ENDIF
	
		oSA2Mod:SetValue("A2_ESTADO",  cDescEst)
		oSA2Mod:SetValue("A2_EST",     cDescEst)
		oSA2Mod:SetValue("A2_COD_MUN", 	cCodMun)
		oSA2Mod:SetValue("A2_MUN",     cDescMun)

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
			cMsgRet += "Campo do erro: " + AllTrim(cValToChar(aErro[04])) + Chr(13) + Chr(10)
			cMsgRet += "Conteudo: " + AllTrim(cValToChar(aErro[09])) + Chr(13) + Chr(10)
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
				'Registro: ' + AllTrim(oRequest['A2_COD']) + " - " + AllTrim(oRequest['A2_NOME']) + ;
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
WSMETHOD GET WSRECEIVE nPage, nPageSize WSSERVICE zCRUDSA2

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
	// exemplo: http://localhost:8080/zCRUDSA2/1
	If Len(::aURLParms) > 0

		IF LEN(::aURLParms[1]) == 6 //C�digo de busca fixado tamanho 6
			cWhere := '%'
			cWhere += " AND A2_COD = '" + AllTrim(::aURLParms[1]) + "' " //Self:aURLParms[1]
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
        A2_COD AS A2_COD,
		A2_LOJA AS A2_LOJA,
		A2_NOME AS A2_NOME,
		A2_ESTADO AS A2_ESTADO,
		A2_COD_MUN AS A2_COD_MUN,
		A2_MUN AS A2_MUN,
		A2_TIPO AS A2_TIPO,
		R_E_C_N_O_ AS R_E_C_N_O_
	FROM %Table:SA2% AS SA2
	WHERE SA2.%NotDel%
		%Exp:cWhere%
	ORDER BY A2_FILIAL, A2_NOME, A2_LOJA

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

				oResponse['A2_COD'] 	:= AllTrim((cAlias)->A2_COD)
				oResponse['A2_LOJA'] 	:= AllTrim((cAlias)->A2_LOJA)
				oResponse['A2_NOME'] 	:= AllTrim((cAlias)->A2_NOME)
				oResponse['A2_ESTADO'] 	:= AllTrim((cAlias)->A2_ESTADO)
				oResponse['A2_COD_MUN'] := AllTrim((cAlias)->A2_COD_MUN)
				oResponse['A2_MUN'] 	:= AllTrim((cAlias)->A2_MUN)
				oResponse['A2_TIPO'] 	:= AllTrim((cAlias)->A2_TIPO)
				oResponse['R_E_C_N_O_'] := (cAlias)->R_E_C_N_O_

				Aadd(aResponse, oResponse)
				FreeObj(oResponse)

				nCount++
				(cAlias)->(DbSkip())
			End

			(cAlias)->(DbCloseArea())
		Else //Retorno vazio consulta SA2
			oResponse['mensage']	:= ENCODEUTF8(;
				'N�o h� retorno de registros da tabela de Fornecedores(SA2).',;
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
