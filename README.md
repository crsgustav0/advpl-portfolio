# Portfólio de Desenvolvimento Protheus – Cristian Gustavo

Este repositório reúne projetos, códigos de estudo e boas práticas voltadas ao desenvolvimento na plataforma **TOTVS Protheus**, utilizando as principais tecnologias e padrões adotados no ecossistema TOTVS:

- **ADVPL** (linguagem proprietária)
- **TLPP** (Totvs Language Pre-Processor)
- **MVC (Model-View-Controller)**
- **PO UI (Portinari UI - Angular)**

---

## Objetivo

Consolidar meu aprendizado prático e compartilhar soluções aplicáveis ao cotidiano de consultoria, personalizações e integrações no ambiente Protheus, com foco em:

- Automação de rotinas empresariais
- Geração de relatórios e dashboards
- Integrações via REST/SOAP
- Desenvolvimento de rotinas MVC e interfaces com PO UI
- Otimizações via SQL Server (T-SQL com MSExecSQL)

---

## Estrutura do Repositório

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

## Projetos em Destaque

| Projeto               | Tecnologias     | Descrição                                               |
| --------------------- | --------------- | ------------------------------------------------------- |
| `u_crud_produtos.prw` | ADVPL + SQL     | CRUD completo na SB1 com validação                      |
| `pedidos_venda.prw`   | ADVPL + SC5/SC6 | Simulação de pedido com itens, impostos e totalizadores |
| `requisicao-compra`   | PO UI + Angular | Front-end SPA integrado com serviço Protheus REST       |
| `MATA951`             | MVC             | Customização nativa com uso de FWMVC e ModelCallback    |

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
    Data início: 25/06/2025
