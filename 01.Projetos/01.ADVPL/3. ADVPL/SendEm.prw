#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} SendEm
	Ponto de Entrada para disparo de e-Mail.
@author Cristian Gustavo Dias Andrade
@since 27/02/2026
/*/

User Function SendEm()

	If FWAlertYesNo("A rotina a seguir realiza o processamento de registros e faz o envio via Gmail, deseja continuar com a operação?", 'Email HTML')
		//Processamento e envio
		U_SendEmOk()
	Else
		FWAlertWarning("Operação cancelada!", 'Email HTML')
	Endif

Return( Nil )

User Function SendEmOk()

	Local cEmail        := SuperGetMv("MV_HTMLEM", .F., "")
	Local cCorpo        := ""
	Local cRet          := ""
	Local aArea         := FWGetArea()
	Local cTitulo       := "Amostra de Qualidade - " + DToC(Date()) + " " + Time()
	Local nOk           := 0
	Local nRetr         := 0

	Local cUnidade      := cEmpAnt + cFilAnt
	Local cQuery        := ""
	Local cQueryCount   := ""
	Local aDados        := {}
	Local aTotal        := {}
	Local nTotalBolsas  := 0
	Local nTotalAmostra := 0
	Local nVolumeQual   := 0
	Local nX            := 0
	Local cUpdate       := ""

	Local cBolsa   := ''
	Local cPedido  := ''
	Local nVolume  := 0
	Local nAmostra := 0
	Local nSeq     := 0

	// ==========================================
	// QUERY PRINCIPAL (AMOSTRA > 0)
	// ==========================================
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " PROs01_BOLSA   AS BOLSA, "
	cQuery += " PROs01_PEDIDO  AS PEDIDO, "
	cQuery += " PROs01_VOLUME  AS VOLUME, "
	cQuery += " PROs01_AMOSTRA AS AMOSTRA, "
	cQuery += " PROs01_SEQ AS SEQ "
	cQuery += " FROM PROs01 "
	cQuery += " WHERE PROs01_UNIDADE = '" + cUnidade + "' "
	cQuery += " AND PROs01_IMPRESSO >= CAST(GETDATE() AS DATE) "
	cQuery += " AND PROs01_IMPRESSO < DATEADD(DAY,1,CAST(GETDATE() AS DATE)) "
	cQuery += " AND PROs01_AMOSTRA > 0 "
	//cQuery += " AND ISNULL(PROs01_AMOSTRA,0) = 0 "


	aDados := u_MDSelect(cQuery)

	// ==========================================
	// QUERY TOTAL DO DIA (SEM FILTRO AMOSTRA)
	// ==========================================
	cQueryCount := ""
	cQueryCount += " SELECT COUNT(*) QTDE "
	cQueryCount += " FROM PROs01 "
	cQueryCount += " WHERE PROs01_UNIDADE = '" + cUnidade + "' "
	cQueryCount += " AND PROs01_IMPRESSO >= CAST(GETDATE() AS DATE) "
	cQueryCount += " AND PROs01_IMPRESSO < DATEADD(DAY,1,CAST(GETDATE() AS DATE)) "

	aTotal := u_MDSelect(cQueryCount)

	If Len(aTotal) > 0
		nTotalBolsas := aTotal[1][1]
	EndIf

	// ==========================================
	// PROCESSAMENTO
	// ==========================================
	If Len(aDados) > 0

		nTotalAmostra := Len(aDados)

		// ==========================================
		// LAYOUT COM PRE-FORMATACAO (STYLE PRE-WRAP)
		// ==========================================
		cCorpo := "<html><body style='font-family: monospace;'>"
		cCorpo += "<pre style='font-family: monospace; white-space: pre;'>"

		cCorpo += "AMOSTRA DE QUALIDADE - " + DToC(Date()) + " " + Time() + CRLF
		cCorpo += CRLF
		cCorpo += "Quantidade Total de Bolsas:   " + cValToChar(nTotalBolsas) + CRLF
		cCorpo += Replicate("-", 60) + CRLF
		cCorpo += "Quantidade de Bolsas selecionadas para Amostra de Qualidade:   " + cValToChar(nTotalAmostra) + CRLF
		cCorpo += CRLF

		// Cabeçalho alinhado (Baseado na imagem solicitada)
		cCorpo += "      " + PadR("Bolsa", 10) + PadR("Pedido", 10) + PadL("Volume", 10) + PadL("Amostra", 10) + PadL("Seq", 6) + CRLF

		For nX := 1 To Len(aDados)

			cBolsa   := AllTrim(aDados[nX][1])
			cPedido  := AllTrim(aDados[nX][2])
			nVolume  := Iif(ValType(aDados[nX][3]) == "C", Val(aDados[nX][3]), aDados[nX][3])
			nAmostra := Iif(ValType(aDados[nX][4]) == "C", Val(aDados[nX][4]), aDados[nX][4])
			nAmostra := Round(nAmostra,0)
			nSeq     := Iif(ValType(aDados[nX][5]) == "C", Val(aDados[nX][5]), aDados[nX][5])

			nVolumeQual += nAmostra

			// Detalhe alinhado
			cCorpo += "      " + PadR(cBolsa, 10) + PadR(cPedido, 10) + PadL(Transform(nVolume, "@E 999,999.99"), 10) + PadL(Transform(nAmostra, "@E 999,999.99"), 10) + PadL(cValToChar(nSeq), 6) + CRLF
			// ==========================================
			// UPDATE WF - MARCA COMO PROCESSADO
			// ==========================================
			cUpdate := ""
			cUpdate += "UPDATE PROs01 SET PROs01_AMOSTRA = 1 "
			cUpdate += "WHERE PROs01_UNIDADE = '" + cUnidade + "' "
			cUpdate += "AND PROs01_BOLSA = '" + cBolsa + "' "
			cUpdate += "AND PROs01_SEQ = " + cValToChar(nSeq)

			If TcSqlExec(cUpdate) < 0
				FWLogMsg("Erro ao executar UPDATE PROs01")
			EndIf

		Next

		cCorpo += "                                          -------" + CRLF
		cCorpo += "                      Volume Qualidade:  " + Transform(nVolumeQual, "@E 999,999.00") + "mL" + CRLF
		cCorpo += Replicate("=", 60) + CRLF
		cCorpo += "</pre>"
		cCorpo += "</body></html>"

		// ==========================================
		// ENVIO FINAL
		// ==========================================
		If U_EnvMail(cEmail, cTitulo, cCorpo, {})
			nOk++
		Else
			nRetr++
		EndIf

	EndIf

	cRet := "Processamento concluído. Sucesso: " + ;
		cValToChar(nOk) + " | Erro: " + cValToChar(nRetr)

	FWAlertInfo(cRet, "Status de Envio")

	FWRestArea(aArea)

Return


User Function EnvMail(cPara, cAssunto, cCorpo, aAnexos)

	Local aArea      := FWGetArea()
	Local cFrom      := Alltrim(SuperGetMv("MV_RELACNT", .F., ""))
	Local cPass      := Alltrim(SuperGetMv("MV_RELPSW", .F., ""))
	Local cSrvFull   := Alltrim(SuperGetMv("MV_RELSERV", .F., "smtp.gmail.com:587"))
	Local cServer    := ""
	Local nPort      := 587
	Local oManager   := Nil
	Local oMessage   := Nil
	Local nRet       := 0
	Local lRet       := .T.

	// Validação
	If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
		Return .F.
	EndIf

	// Quebra servidor/porta
	If ":" $ cSrvFull
		cServer := SubStr(cSrvFull, 1, At(":", cSrvFull) - 1)
		nPort   := Val(SubStr(cSrvFull, At(":", cSrvFull) + 1))
	Else
		cServer := cSrvFull
	EndIf

	// Instancia manager
	oManager := TMailManager():New()

	// Configuração SSL/TLS
	If nPort == 465
		oManager:SetUseSSL(.T.)
		oManager:SetUseTLS(.F.)
	Else
		oManager:SetUseSSL(.F.)
		oManager:SetUseTLS(.T.)
	EndIf

	oManager:SetSmtpTimeOut(120)

	// Init
	nRet := oManager:Init("", cServer, cFrom, cPass, 0, nPort)
	If nRet <> 0
		ConOut("Erro Init SMTP: " + oManager:GetErrorString(nRet))
		FWRestArea(aArea)
		Return .F.
	EndIf

	// Conecta
	nRet := oManager:SmtpConnect()
	If nRet <> 0
		ConOut("Erro Conexão SMTP: " + oManager:GetErrorString(nRet))
		oManager:SmtpDisconnect()
		FWRestArea(aArea)
		Return .F.
	EndIf

	// Autentica
	nRet := oManager:SmtpAuth(cFrom, cPass)
	If nRet <> 0
		ConOut("Erro Login SMTP: " + oManager:GetErrorString(nRet))
		oManager:SmtpDisconnect()
		FWRestArea(aArea)
		Return .F.
	EndIf

	// Monta mensagem
	oMessage := TMailMessage():New()

	oMessage:cFrom    := cFrom
	oMessage:cTo      := cPara
	oMessage:cSubject := cAssunto
	oMessage:cBody    := cCorpo
	// HTML será interpretado automaticamente se houver tags <html>

	// Anexos
	If ValType(aAnexos) == "A" .And. Len(aAnexos) > 0
		AEval(aAnexos, {|cFile| oMessage:AddAttachment(cFile)})
	EndIf

	// ENVIO CORRETO PARA SUA LIB
	nRet := oMessage:Send(oManager)

	If nRet <> 0
		ConOut("Erro Envio: " + oManager:GetErrorString(nRet))
		lRet := .F.
	EndIf

	oManager:SmtpDisconnect()

	FWRestArea(aArea)

Return lRet

User Function MDSelect(cQuery)

	Local aRet   := {}
	Local cAlias := GetNextAlias()
	Local nI

	TCQuery cQuery Alias (cAlias) New

	If (cAlias)->(Eof())
		(cAlias)->(DbCloseArea())
		Return {}
	EndIf

	(cAlias)->(DbGoTop())

	While !(cAlias)->(Eof())

		AAdd(aRet, {})

		For nI := 1 To FCount()
			AAdd(aRet[Len(aRet)], FieldGet(nI))
		Next

		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())

Return aRet
