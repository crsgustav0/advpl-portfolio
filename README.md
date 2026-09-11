# Portf�lio de Desenvolvimento Protheus � Cristian Gustavo

Este reposit�rio re�ne projetos, c�digos de estudo e boas pr�ticas voltadas ao desenvolvimento na plataforma **TOTVS Protheus**, utilizando as principais tecnologias e padr�es adotados no ecossistema TOTVS:

- **ADVPL** (linguagem propriet�ria)
- **TLPP** (Totvs Language Pre-Processor)
- **MVC (Model-View-Controller)**
- **PO UI (Portinari UI - Angular)**

---

## Objetivo

Consolidar meu aprendizado pr�tico e compartilhar solu��es aplic�veis ao cotidiano de consultoria, personaliza��es e integra��es no ambiente Protheus, com foco em:

- Automa��o de rotinas empresariais
- Gera��o de relat�rios e dashboards
- Integra��es via REST/SOAP
- Desenvolvimento de rotinas MVC e interfaces com PO UI
- Otimiza��es via SQL Server (T-SQL com MSExecSQL)

---

## Estrutura do Reposit�rio

    protheus-dev-portfolio/
    Projetos
        advpl/
        u_crud_produtos.prw
        u_pedidos_venda.prw
        includes/
        
        mvc/
         MATA951/
          Model/
          View/
          Controller/
         README.md
        
        poui/
         requisicao-compra/
         dashboard-vendas/
         README.md
        
        sql/
         scripts/
          create_zp1_log.sql
          optimize_se5.sql
        
        docs/
         imagens, diagramas e prints
        
    README.md

---

## Nova inclusão em destaque

A estrutura do portfólio foi ampliada com o módulo de clientes em TLPP, que representa uma implementação prática de Web Service REST no Protheus para manipulação da tabela SA1. Esse novo fonte reforça o alinhamento entre:

- TLPP como linguagem de customização
- arquitetura MVC aplicada em camadas
- leitura otimizada via SQL embutido
- manutenção de dados com validação nativa do Protheus (`CRMA980`)
- exposição de endpoints REST para consumo por aplicações externas

Esse módulo passa a compor o conjunto de estudos e soluções do portfólio como referência de integração e integração de cadastro de clientes.

## Projetos em Destaque

| Projeto                       | Tecnologias                 | Descrição                                                                  |
| ----------------------------- | -------------------------- | -------------------------------------------------------------------------- |
| `WS TLPP Clientes (SA1)`      | TLPP + REST + MVC          | Web Service para consulta, inclusão, alteração e exclusão lógica de clientes |
| `u_crud_produtos.prw`         | ADVPL + SQL                | CRUD completo na SB1 com validação                                         |
| `pedidos_venda.prw`           | ADVPL + SC5/SC6            | Simulação de pedido com itens, impostos e totalizadores                    |
| `requisicao-compra`           | PO UI + Angular            | Front-end SPA integrado com serviço Protheus REST                          |
| `MATA951`                     | MVC                        | Customização nativa com uso de FWMVC e ModelCallback                       |

---

## Ferramentas Utilizadas

- **Protheus 12.1.27 / 12.1.33**
- **TOTVS Developer Studio (TDS)**
- **SQL Server 2016+**
- **Angular + PO UI**
- **Git + GitHub**
- **Insomnia / Postman (REST testing)**

---

## Autor

**Cristian Gustavo** | Consultor e desenvolvedor TOTVS Protheus

- [LinkedIn Cristian Gustavo](https://www.linkedin.com/in/cristian-gustavo-719aa71b2/)
- [GitHub Cristian Gustavo](https://github.com/crsgustav0)

---

    Desenvolvido e documentado por: Cristian Gustavo
    Data in�cio: 25/06/2025
