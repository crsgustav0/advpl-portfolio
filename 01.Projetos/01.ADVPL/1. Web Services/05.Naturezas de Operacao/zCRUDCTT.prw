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

/*/{Protheus.doc} ZCrudCTT
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
WSRESTFUL zCRUDCTT DESCRIPTION "Web Service Rest C. Custo(CTT)" FORMAT APPLICATION_JSON

	WSDATA CTT_CUSTO AS CHARACTER OPTIONAL
	WSDATA nPageSize AS INTEGER OPTIONAL
	WSDATA nPage     AS INTEGER OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "Consulta tabela C. Custo(CTT)";
		WSSYNTAX "/zCRUDCTT || /'zCRUDCTT'/{CTT_CUSTO}" //Não possibilita utilizar outro GET
	
	WSMETHOD POST;
		DESCRIPTION "Inserção tabela C. Custo(CTT) via CTBA030";
		WSSYNTAX "/zCRUDCTT"

	WSMETHOD PUT;
		DESCRIPTION "Alteração tabela C. Custo(CTT) via CTBA030";
		WSSYNTAX "/zCRUDCTT"

	WSMETHOD DELETE;
		DESCRIPTION "Deleção tabela C. Custo(CTT) via CTBA030";
		WSSYNTAX "/zCRUDCTT || /'zCRUDCTT'/{CTT_CUSTO}"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE
DELETE no modelo antigo WSSYNTAX que valida requisição via path

@author Cristian Gustavo
@since 15/08/2025
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE WSSERVICE zCRUDCTT

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
	// exemplo: http://localhost:8080/zCRUDCTT/000001
	If Len(::aURLParms) > 0

		IF LEN(::aURLParms[1]) == 6 //Código de busca fixado tamanho 6
			cCodCTT	:= AllTrim(::aURLParms[1])

			If !Empty(cCodCTT)
				DBSelectArea("CTT")
				CTT->(DbSetOrder(1))
				If CTT->(DbSeek(xFilial("CTT") + cCodCTT))
					// Define campos obrigatórios para deleção
					aAdd(aDados, {"CTT_CUSTO",  CTT->CTT_CUSTO, Nil})
					aAdd(aDados, {"CTT_DESC01",  CTT->CTT_DESC01, Nil})

					// Executa a rotina automática
					MSExecAuto({|x,y|CTBA030(x,y)}, aDados, MODEL_OPERATION_DELETE)

					If lMsErroAuto
						cMsgRet := retErro()
					Else
						cMsgRet := "C. Custo " + cCodCTT + " excluída com sucesso!"
					EndIf
				Else
					cMsgRet += "C. Custo não encontrado para exclusão." + Chr(13) + Chr(10)
				EndIf
			Else
				cMsgRet	:= 'Campo: CTT_CUSTO' + ' não informado no endereço da requisição!'
			EndIf

		Else
			cMsgRet	:= 'Código informado deve conter 6 caracteres.'
		EndIf

	Else
		cMsgRet	:= 'Campo: CTT_CUSTO' + ' não informado no endereço da requisição!'
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
WSMETHOD PUT WSSERVICE zCRUDCTT

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
		aAdd(aDados, {"CTT_CUSTO", AllTrim(oRequest['CTT_CUSTO']), Nil})
		aAdd(aDados, {"CTT_DESC01", AllTrim(oRequest['CTT_DESC01']), Nil})

		// Executa a rotina automática
		MSExecAuto({|x,y|CTBA030(x,y)}, aDados, MODEL_OPERATION_UPDATE)

		If lMsErroAuto
			cMsgRet := retErro()
		Else
			cMsgRet := "C. Custo " + AllTrim(oRequest['CTT_CUSTO']) + " - " + AllTrim(oRequest['CTT_CUSTO']) + " alterada com sucesso!"
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
POST utilizando ExecAuto para inclusão de registro CTT

@author Cristian Gustavo
@since 20/09/2025
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE zCRUDCTT

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
		aAdd(aDados, {"CTT_FILIAL", xFilial("CTT"), Nil})
		aAdd(aDados, {"CTT_CUSTO", AllTrim(oRequest['CTT_CUSTO']), Nil})
		aAdd(aDados, {"CTT_DESC01", AllTrim(oRequest['CTT_DESC01']), Nil})

		// Executa a rotina automática
		MSExecAuto({|x,y|CTBA030(x,y)}, aDados, MODEL_OPERATION_INSERT)

		If lMsErroAuto
			cMsgRet := retErro()
		Else
			cMsgRet := "C. Custo " + AllTrim(oRequest['CTT_CUSTO']) + ;
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
WSMETHOD GET WSRECEIVE nPage, nPageSize WSSERVICE zCRUDCTT

	Local aResponse	 as Array
	Local lRetWS	 as Logical

	Local nI         as Numeric
	Local nCount     as Numeric
	Local nStart   	 as Numeric

	Local jResponse  as Object
	Local oResponse  as Object

	Local cAlias 	 as Character
	Local cMsgRet 	 as Character
	Local cWhere 	 as Character

	DEFAULT ::nPage := 1, ::nPageSize := 5

	aResponse   := {}
	lRetWS		:= .T.

	nI          := 0
	nCount      := 0

	jResponse   := JsonObject():New()
	oResponse   := JsonObject():New()

	cAlias 		:= GetNextAlias()
	cMsgRet 	:= ''
	cWhere 		:= '%%'

	nStart   	:= (::nPage - 1) * ::nPageSize

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/zCRUDCTT/1
	If Len(::aURLParms) > 0

		IF LEN(::aURLParms[1]) == 6 //Código de busca fixado tamanho 6
			cWhere := '%'
			cWhere += " AND CTT_CUSTO = '" + AllTrim(::aURLParms[1]) + "' " //Self:aURLParms[1]
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
    	    CTT_FILIAL AS CTT_FILIAL,
			CTT_CUSTO AS CTT_CUSTO,
			CTT_DESC01 AS CTT_DESC01,
			R_E_C_N_O_ AS R_E_C_N_O_
		FROM %Table:CTT% AS CTT
		WHERE CTT.%NotDel%
			%Exp:cWhere%

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

				oResponse['CTT_FILIAL'] 	:= AllTrim((cAlias)->CTT_FILIAL)
				oResponse['CTT_CUSTO'] 	:= AllTrim((cAlias)->CTT_CUSTO)
				oResponse['CTT_DESC01'] 	:= AllTrim((cAlias)->CTT_DESC01)
				oResponse['R_E_C_N_O_'] := (cAlias)->R_E_C_N_O_

				Aadd(aResponse, oResponse)
				FreeObj(oResponse)

				nCount++
				(cAlias)->(DbSkip())
			End

			(cAlias)->(DbCloseArea())
		Else //Retorno vazio consulta CTT
			oResponse['mensage']	:= ENCODEUTF8(;
				'Não há retorno de registros da tabela de C. Custo(CTT).',;
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

Static Function retErro()

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
