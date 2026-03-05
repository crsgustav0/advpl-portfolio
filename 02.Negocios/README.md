# Portfólio de Desenvolvimento Protheus – Cristian Gustavo

Este repositório reúne conhecimentos direcionados a negócios do Sistema Protheus, com foco no módulo Financeiro, tendo como principais objetivos:

- **Aprimorar entendimento referente ao módulo Financeiro do ERP Protheus**
- **Execução, uso e aplicação de análise, entendimento conforme necessidades do módulo.**

---

## Estruturação do Curso

- **Introdução**
- **Desenvolvimento**
  - Cadastros
  - Contas a Pagar
  - Contas a Receber
  - Movimento Bancário
  - Caixinha
  - Aplicação/ Empréstimo
  - Integração Contábil
  - Relatórios
- **Conclusão**
- **Exercícios de fixação**

## Relação Rotinas Cadastro x Tabelas x Documentação

| Rotina                            | Módulo      | Tabela | Rotina  | Doc.                                                                                                                       |
| --------------------------------- | ----------- | ------ | ------- | -------------------------------------------------------------------------------------------------------------------------- |
| **Cad. Moedas**                   | **Compras** | SM2    | MATA090 | [Cad. Moedas](01.Compras/02.Cadastros/01.Moedas/Cadastro_Moedas.md)                                                        |
| **Cad. Produtos**                 | **Compras** | SB5    | MATA010 | [Cad. Produtos](01.Compras/02.Cadastros/02.Produtos/Cadastro_Produtos.md)                                                  |
| **Cad. Fornecedor**               | **Compras** | SA5    | MATA061 | [Cad. Fornecedor](01.Compras/02.Cadastros/03.Fornecedor/Cadastro_ProdutosFornecedor.md)                                    |
| **Cad. Prod. x Fornec.**          | **Compras** | SA5    | MATA061 | [Cad. Prod. x Fornec.](01.Compras/02.Cadastros/03.Produtos%20x%20Fornecedor/Cadastro_Fornecedor.md)                        |
| **Cad. Grupo. x Fornec.**         | **Compras** | SAD    | MATA065 | [Cad. Grupo. x Fornec.](01.Compras/02.Cadastros/03.2.Grupos%20x%20Fornecedor/Cadastro_GrupoFornecedor.md)                  |
| **Cad. Condic. Pagamentos**       | **Compras** | SE4    | MATA360 | [Cad. Condic. Pagamentos](01.Compras/02.Cadastros/04.Cond.%20Pagamentos/Cadastro_CondicaoPagamentos.md)                    |
| **Cad. Tipo Entrada Saída (TES)** | **Compras** | SF4    | MATA080 | [Cad. Tipo Entrada Saída (TES) ](<01.Compras/02.Cadastros/05.Tipo%20Entrada%20Saida%20(TES)/Cadastro_TipoEntradaSaida.md>) |
| **Cad. Naturezas Financeiras**    | **Compras** | SED    | FINA010 | [Cad. Naturezas Financeiras ](<01.Compras/02.Cadastros/06.Naturezas Financeiras/Cadastro_NaturezasFinanceiras.md>)         |
| **Cad. NCM**                      | **Compras** | SYD    | EICA130 | [Cad. NCM](01.Compras/02.Cadastros/07.NCM/Cadastro_NCM.md)                                                                 |
| **Cad. Motivos de Retorno**       | **Compras** | DHI    | MATA104 | [Cad. Motivos de Retorno](01.Compras/02.Cadastros/08.Motivos%20de%20Retorno/Cadastro_Motivos%20de%20Retorno.md)            |

## Relação Adminstração Rotinas x Tabelas x Documentação

| Rotina                             | Módulo      | Tabela        | Rotina  | Doc.                                                                                                                                           |
| ---------------------------------- | ----------- | ------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cad. Tabela de Preços**          | **Compras** | AIA, AIB      | COMA010 | [Cad. Tabela de Preços](01.Compras/03.Administração%20de%20Compras/01.Tabela%20de%20Preço/TabelaPreços.md)                                     |
| **Cad. Tolerância de Recebimento** | **Compras** | AIC           | COMA020 | [Cad. Tolerância de Recebimento](01.Compras/03.Administração%20de%20Compras/02.Tolerancia%20de%20Recebimento/Tolerancia%20de%20Recebimento.md) |
| **Cad. Entrega por Terceiros**     | **Compras** | CPW, CPX      | COMA010 | [Cad. Entrega por Terceiros](01.Compras/03.Administração%20de%20Compras/03.Entrega%20por%20Terceiros/Entrega%20por%20Terceiros.md)             |
| **Cad. Solicitantes**              | **Compras** | CPW, CPX, DBK | MATA084 | [Cad. Solicitantes](01.Compras/03.Administração%20de%20Compras/03.Solicitantes/Solicitantes.md)                                                |
| **Cad. Compradores**               | **Compras** | SY1           | COMA087 | [Cad. Compradores](01.Compras/03.Administração%20de%20Compras/04.Compradores/Compradores.md)                                                   |
| **Cad. Grupo de Compras**          | **Compras** | SAJ           | COMA086 | [Cad. Grupo de Compras](01.Compras/03.Administração%20de%20Compras/05.Grupo%20de%20Compras/Grupo%20de%20Compras.md)                            |
| **Cad. Aprovadores**               | **Compras** | SAK           | MATA095 | [Cad. Aprovadores](01.Compras/03.Administração%20de%20Compras/06.Aprovadores/Aprovadores.md)                                                   |
| **Cad. Perfil de Aprovadores**     | **Compras** | DHL           | COMA210 | [Cad. Perfil de Aprovadores](01.Compras/03.Administração%20de%20Compras/07.Perfil%20de%20Aprovadores/Perfil%20de%20Aprovadores.md)             |
| **Cad. Grupo de Aprovação**        | **Compras** | SAL           | MATA114 | [Cad. Grupo de Aprovação](01.Compras/03.Administração%20de%20Compras/08.Grupo%20de%20Aprovação/Grupo%20de%20Aprovação.md)                      |

---

## Conceito ERP

- **Software ERP - Enterprise Resource Planning**

**Programa de Gestão Empresarial** que integra e automatiza os principais processos de um negócio, empresa como Finanças, RH, Vendas, Compras e Estoque em uma única plataforma, ferramenta, funcionando como um centralizador de uma empresa, possibilitando e fornecendo uma visão unificada das operações, recursos.

Tendo como características:

- Banco de dados compartilhado
- Múltiplos acessos
- Integração entre diversos módulos

---

## Entedimento inicial - ERP Protheus

**ERP Protheus** é um sistema de gestão empresarial (ERP) modular, desenvolvido pela TOTVS, responsável pela integração e a centralização de diversas áreas de uma empresa em um único ambiente, tendo como principais características:

- **ERP líder na América Latina**
- Atendimento a diversos segmentos
- **Grande variedade de módulos**
  - Compras, Faturameto
- **Personalização**

  Permite a inclusão de customizações em rotinas, integrações com outras ferramentas.

- **Adaptado à legislação brasileira**

---

## Principais módulos ERP Protheus

- **Faturamento**
  - Controle de pedidos de vendas
  - Liberação de pedidos
  - Controle de orçamentos
  - Geração, emissão de faturamento
  - Transmissão de Notas SEFAZ
- **Financeiro**
  - Controle de contas a pagar, receber
  - Envio de CNAB
  - Controle de aplicações, empréstimos
- **Estoque**
  - Controle de materiais:
    - Solicitações de materias
    - Inventários
    - Apontamento de Produção
    - Solicitações de Estoque
- **Compras**
  - Controle de Compras
  - Liberação de Pedidos
  - Controle de Solicitação de Compras:
- **Livros Fiscais**

  Todas as informações geradas pelos módulos anteriores, todas as informações faturadas, que possui retenção de impostos via Financeiro, geração de impostos são controlados e a criação de arquivos são feitos pelo módulos Livros Fiscais.

- **Contabilidade**

  Todas as informações geradas pelos módulos Financeiro, Estoque, Compras, Livros Fiscais são direcionadas para a Contabilidade faz o controle de lançamentos contábeis.

- **Gestão de Pessoal**

  Controle de folha de pagamento, controle de funcionários, geração de folhas, pagamentos e entre outros.

---

## Ferramentas Utilizadas

- **TOTVS Developer Studio (TDS)**
- **Git + GitHub**

---

## Autor

**Cristian Gustavo** | Consultor e desenvolvedor TOTVS Protheus

- [LinkedIn Cristian Gustavo](https://www.linkedin.com/in/cristian-gustavo-719aa71b2/)
- [GitHub Cristian Gustavo](https://github.com/crsgustav0)

---

    Desenvolvido e documentado por: Cristian Gustavo
    Data início: 17/11/2025
