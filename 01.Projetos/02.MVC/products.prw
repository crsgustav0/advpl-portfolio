#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'

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

User Function ZCrudSB1()

	Local cOpc  := ""
	Local cCod  := ""
	Local aMenu := {"1 - Incluir", "2 - Alterar", "3 - Consultar", "4 - Excluir", "5 - Sair"}

	While cOpc != "5"
		cOpc := aMenu[ ACHOICE( , , aMenu ) ]

		Do Case
		Case cOpc == "1"
			U_ZIncSB1()
		Case cOpc == "2"
			U_ZAltSB1()
		Case cOpc == "3"
			U_ZConSB1()
		Case cOpc == "4"
			U_ZDelSB1()
		EndCase
	End While

Return

// Inclus�o
User Function ZIncSB1()
	Local cCod := Space(15)
	Local cDesc := Space(40)

	cCod  := InputBox("Informe o c�digo do produto:")
	cDesc := InputBox("Informe a descri��o do produto:")

	DbSelectArea("SB1")
	DbSetOrder(1)
	If !DbSeek(cCod)
		RecLock("SB1", .T.)
		SB1->B1_COD := cCod
		SB1->B1_DESC := cDesc
		SB1->B1_TIPO := "PA" // Produto Acabado
		SB1->B1_UM := "PC"
		MsUnlock()
		MsgInfo("Produto inclu�do com sucesso!")
	Else
		MsgStop("Produto j� existe.")
	EndIf
Return

// Altera��o
User Function ZAltSB1()
	Local cCod := InputBox("Informe o c�digo do produto:")
	DbSelectArea("SB1")
	DbSetOrder(1)

	If DbSeek(cCod)
		RecLock("SB1", .F.)
		SB1->B1_DESC := InputBox("Nova descri��o:", SB1->B1_DESC)
		MsUnlock()
		MsgInfo("Produto alterado.")
	Else
		MsgStop("Produto n�o encontrado.")
	EndIf
Return

// Consulta
User Function ZConSB1()
	Local cCod := InputBox("Informe o c�digo do produto:")
	DbSelectArea("SB1")
	DbSetOrder(1)

	If DbSeek(cCod)
		MsgInfo("Descri��o: " + SB1->B1_DESC + Chr(13) + "UM: " + SB1->B1_UM)
	Else
		MsgStop("Produto n�o encontrado.")
	EndIf
Return

// Exclus�o
User Function ZDelSB1()
	Local cCod := InputBox("Informe o c�digo do produto:")
	DbSelectArea("SB1")
	DbSetOrder(1)

	If DbSeek(cCod)
		If MsgYesNo("Deseja excluir o produto " + SB1->B1_DESC + "?")
			RecLock("SB1", .F.)
			DbDelete()
			MsUnlock()
			MsgInfo("Produto exclu�do.")
		EndIf
	Else
		MsgStop("Produto n�o encontrado.")
	EndIf
Return
