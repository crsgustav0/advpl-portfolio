#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

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
WSRESTFUL zCRUDSB1 DESCRIPTION "Web Service Cadastro Produtos(SB1)" FORMAT APPLICATION_JSON

	WSDATA pageSize AS INTEGER OPTIONAL
	WSDATA page AS INTEGER OPTIONAL
	WSDATA path1 AS CHARACTER OPTIONAL
	WSDATA path2 AS CHARACTER OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "Consulta tabela Produtos(SB1)";
		WSSYNTAX "/zCRUDSB1 || /zCRUDSB1/{B1_COD}" //Não possibilita utilizar outro GET

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Get no modelo antigo WSSYNTAX que não valida agrupamentos e nem path

@author Vinicius Ledesma
@since 05/09/2018
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE page, pageSize WSSERVICE zCRUDSB1

	Local aResponse	 as Array
	Local nI         as Numeric
	Local jResponse  as Object
	Local oResponse  as Object
	local cAlias 	 as Character

	aResponse   := {}
	nI          := 0
	jResponse   := JsonObject():New()
	oResponse   := JsonObject():New()
	cAlias 		:= GetNextAlias()

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
	ORDER BY B1_FILIAL, B1_COD 

	ENDSQL

	//Se não encontrar registros
	If !(cAlias)->(EoF())
		While !( (cAlias)->(EoF()) )
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

			(cAlias)->(DbSkip())
		End

		(cAlias)->(DbCloseArea())
	Else //Retorno vazio consulta SB1
		oResponse['mensage']	:= ENCODEUTF8(;
			'Não há retorno de registros da tabela de Produtos(SB1).',;
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
