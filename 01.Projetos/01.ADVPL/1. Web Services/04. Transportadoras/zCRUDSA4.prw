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

/*/{Protheus.doc} ZCrudSA4
    (long_description)
    @type  Function
    @author Cristian Gustavo
    @since 15/08/2025
    @version 
        1.0 Desenvolvimento inicial rotina
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
WSRESTFUL zCRUDSA4 DESCRIPTION "Web Service Rest Transportadoras(SA4)" FORMAT APPLICATION_JSON

	WSDATA A4_COD    AS CHARACTER OPTIONAL
	WSDATA nPageSize AS INTEGER OPTIONAL
	WSDATA nPage     AS INTEGER OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "Consulta tabela Transportadoras(SA4)";
		WSSYNTAX "/zCRUDSA4 || /'zCRUDSA4'/{A4_COD}" //Não possibilita utilizar outro GET

	WSMETHOD POST;
		DESCRIPTION "Inserção tabela Transportadoras(SA4) via MATA050";
		WSSYNTAX "/zCRUDSA4"

	WSMETHOD PUT;
		DESCRIPTION "Alteração tabela Transportadoras(SA4) via MATA050";
		WSSYNTAX "/zCRUDSA4"

	WSMETHOD DELETE;
		DESCRIPTION "Deleção tabela Transportadoras(SA4) via MATA050";
		WSSYNTAX "/zCRUDSA4 || /'zCRUDSA4'/{A4_COD}"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE
DELETE no modelo antigo WSSYNTAX que valida requisição via path

@author Cristian Gustavo
@since 15/08/2025
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE WSSERVICE zCRUDSA4

	Local aResponse	 		as Array
	Local aDados     		as Array
	Local cMsgRet	 		as Character

	Local jResponse  		as Object
	Local oRequest   		as Object
	Local oResponse  		as Object

	Local lRetWS	 		as Logical

	Private lMsErroAuto 	as Logical
	Private lAutoErrNoFile 	as Logical

	aResponse   	:= {}
	aDados	    	:= {}
	cMsgRet			:= ''

	jResponse   	:= JsonObject():New()
	oRequest    	:= JsonObject():New()
	oResponse   	:= JsonObject():New()

	lRetWS			:=	oRequest:FromJson(::GetContent()) // Self:GetContent() | Pega a string do JSON
	lMsErroAuto		:=	.F.
	lAutoErrNoFile  := .T. // ESSENCIAL para GetAutoGRLog()

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/zCRUDSA4/000001
	If Len(::aURLParms) > 0

		IF LEN(::aURLParms[1]) == 6 //Código de busca fixado tamanho 6
			cCodSA4	:= AllTrim(::aURLParms[1])

			If !Empty(cCodSA4)
				DBSelectArea("SA4")
				SA4->(DbSetOrder(1))
				If SA4->(DbSeek(xFilial("SA4") + cCodSA4))
					// Define campos obrigatórios para deleção
					aAdd(aDados, {"A4_COD",  SA4->A4_COD, Nil})
					aAdd(aDados, {"A4_NOME", SA4->A4_NOME, Nil})

					// Executa a rotina automática
					MSExecAuto({|x,y|MATA050(x,y)}, aDados, MODEL_OPERATION_DELETE)

					If lMsErroAuto
						cMsgRet := U_retErro()
					Else
						cMsgRet := "Transportadora " + cCodSA4 + " excluída com sucesso!"
					EndIf
				Else
					cMsgRet += "Transportadoras não encontrado para exclusão." + Chr(13) + Chr(10)
				EndIf
			Else
				cMsgRet	:= 'Campo: A4_COD' + ' não informado no endereço da requisição!'
			EndIf

		Else
			cMsgRet	:= 'Código informado deve conter 6 caracteres.'
		EndIf

	Else
		cMsgRet	:= 'Campo: A4_COD' + ' não informado no endereço da requisição!'
	EndIf

	oResponse['mensage'] := ENCODEUTF8(cMsgRet, TYPE_FORM_RETWS)
	Aadd(aResponse, oResponse)
	FreeObj(oResponse)

	Self:SetContentType("application/json")
	Self:SetResponse(aResponse)
	Self:SetStatus(WSCODE_OK)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT
PUT no modelo antigo WSSYNTAX que valida corpo da requisição via JSON

@author Cristian Gustavo
@since 15/08/2025
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSSERVICE zCRUDSA4

	Local aResponse	 		as Array
	Local aDados     		as Array
	Local cMsgRet	 		as Character

	Local jResponse  		as Object
	Local oRequest   		as Object
	Local oResponse  		as Object

	Local lRetWS	 		as Logical
	Private lMsErroAuto		as Logical
	Private lAutoErrNoFile  as Logical

	aResponse  		:= {}
	aDados	   		:= {}
	cMsgRet			:= ''

	jResponse  		:= JsonObject():New()
	oRequest   		:= JsonObject():New()
	oResponse  		:= JsonObject():New()

	lRetWS			:=	oRequest:FromJson(::GetContent()) // Self:GetContent() | Pega a string do JSON
	lMsErroAuto		:=	.F.
	lAutoErrNoFile  := .T. // ESSENCIAL para GetAutoGRLog()

	If ValType(lRetWS) == 'U'

		// Define campos obrigatórios para alteração
		//aAdd(aDados, {"A4_FILIAL", xFilial("SA4"), Nil})
		aAdd(aDados, {"A4_COD",    AllTrim(oRequest['A4_COD']), Nil})
		aAdd(aDados, {"A4_NOME",   AllTrim(oRequest['A4_NOME']), Nil})

		// Executa a rotina automática
		MSExecAuto({|x,y|MATA050(x,y)}, aDados, MODEL_OPERATION_UPDATE)

		If lMsErroAuto
			cMsgRet := U_retErro()
		Else
			cMsgRet := "Transportadora " + AllTrim(oRequest['A4_COD']) + " - " + AllTrim(oRequest['A4_NOME']) + " alterada com sucesso!"
		EndIf
	Else
		cMsgRet := "Corpo da requisição fora do padrão JSON."
	EndIf

	oResponse['mensage'] := ENCODEUTF8(cMsgRet, TYPE_FORM_RETWS)
	Aadd(aResponse, oResponse)
	FreeObj(oResponse)

	Self:SetContentType("application/json")
	Self:SetResponse(aResponse)
	Self:SetStatus(WSCODE_OK)

Return .T.

/*/{Protheus.doc} POST
POST utilizando ExecAuto para inclusão de registro SA4

@author Cristian Gustavo
@since 20/09/2025
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE zCRUDSA4

	Local aResponse	 	as Array
	Local aDados     	as Array
	Local cMsgRet	 	as Character

	Local jResponse  	as Object
	Local oRequest   	as Object
	Local oResponse  	as Object

	Local lRetWS	 	as Logical

	Private lMsErroAuto	    as Logical
	Private lAutoErrNoFile  as Logical

	aResponse   := {}
	aDados      := {}
	cMsgRet		:= ''

	jResponse   := JsonObject():New()
	oRequest    := JsonObject():New()
	oResponse   := JsonObject():New()

	// Pega o JSON da requisição
	lRetWS := oRequest:FromJson(::GetContent())

	lMsErroAuto 	:= .F.
	lAutoErrNoFile  := .T. // ESSENCIAL para GetAutoGRLog()

	If ValType(lRetWS) == 'U'

		// Define campos obrigatórios para inclusão
		aAdd(aDados, {"A4_FILIAL", xFilial("SA4"), Nil})
		aAdd(aDados, {"A4_COD",    AllTrim(oRequest['A4_COD']), Nil})
		aAdd(aDados, {"A4_NOME",   AllTrim(oRequest['A4_NOME']), Nil})

		// Executa a rotina automática

		MSExecAuto({|x,y|MATA050(x,y)}, aDados, MODEL_OPERATION_INSERT)

		If lMsErroAuto
			cMsgRet := U_retErro()
		Else
			cMsgRet := "Transportadora " + AllTrim(oRequest['A4_COD']) + ;
				" - " + AllTrim(oRequest['A4_NOME']) + " incluída com sucesso!"
		EndIf
	Else
		cMsgRet := "Corpo da requisição fora do padrão JSON."
	EndIf

	oResponse['mensage'] := ENCODEUTF8(cMsgRet, TYPE_FORM_RETWS)
	Aadd(aResponse, oResponse)
	FreeObj(oResponse)

	Self:SetContentType("application/json")
	Self:SetResponse(aResponse)
	Self:SetStatus(WSCODE_OK)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Get no modelo antigo WSSYNTAX que valida agrupamentos e path

@author Cristian Gustavo
@since 15/08/2025
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE nPage, nPageSize WSSERVICE zCRUDSA4

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
	// exemplo: http://localhost:8080/zCRUDSA4/1
	If Len(::aURLParms) > 0

		IF LEN(::aURLParms[1]) == 6 //Código de busca fixado tamanho 6
			cWhere := '%'
			cWhere += " AND A4_COD = '" + AllTrim(::aURLParms[1]) + "' " //Self:aURLParms[1]
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
        A4_COD AS A4_COD,
		A4_NOME AS A4_NOME,
		R_E_C_N_O_ AS R_E_C_N_O_
	FROM %Table:SA4% AS SA4
	WHERE SA4.%NotDel%
		%Exp:cWhere%
	ORDER BY A4_COD, A4_NOME

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

				oResponse['A4_COD'] 	:= AllTrim((cAlias)->A4_COD)
				oResponse['A4_NOME'] 	:= AllTrim((cAlias)->A4_NOME)
				oResponse['R_E_C_N_O_'] := (cAlias)->R_E_C_N_O_

				Aadd(aResponse, oResponse)
				FreeObj(oResponse)

				nCount++
				(cAlias)->(DbSkip())
			End

			(cAlias)->(DbCloseArea())
		Else //Retorno vazio consulta SA4
			oResponse['mensage']	:= ENCODEUTF8(;
				'Não há retorno de registros da tabela de Transportadoras(SA4).',;
				TYPE_FORM_RETWS)
		EndIf

	ENDIF

	IF oResponse <> NIL
		Aadd(aResponse, oResponse)

		/*Liberação objetos JSON*/
		FreeObj(oResponse)
	ENDIF

	oResponse['mensage'] := ENCODEUTF8(cMsgRet, TYPE_FORM_RETWS)
	Aadd(aResponse, oResponse)
	FreeObj(oResponse)

	Self:SetContentType("application/json")
	Self:SetResponse(aResponse)
	Self:SetStatus(WSCODE_OK)

Return .T.

User Function retErro()

	Local cLog		as Character
	Local aLogAuto 	as Array
	Local nY 		as Numeric

	cLog 		:= ''
	aLogAuto	:= {}
	nY	 		:= 0

	aLogAuto := GetAutoGRLog()
	For nY := 1 To Len(aLogAuto)
		cLog += aLogAuto[nY] + CRLF
	Next

Return cLog
