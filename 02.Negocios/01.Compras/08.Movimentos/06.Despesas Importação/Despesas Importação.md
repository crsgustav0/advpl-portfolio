# Administração Módulo Compras

**Rotina Despesas Importação**

O cadastro de Despesas Importação feitas no Protheus é feito via **"Módulo 06 - Compras"**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **MATA110.PRW** e suas informações podem ser encontradas na tabelas **"Tabela de Despesas Importação - SC8"**.

[SC8 - Despesas Importação | ERP Labs](https://erplabs.com.br/SC8)

# Gera Despesas Importação

Rotina Protheus:

![alt text](src/MATA131.png)

**Obs: A rotina é semelhante a rotina de Despesa de Conhecimento de Frete, ao invés de atrelhar Notas a Conhecimento de Frete faz a relação a Nota de Despesa sob a Nota de Importação, isso quando o Módulo de Importação não é utilizado**.

## Parâmetros

Necessário informar os parâmetros para retorno de dados, sendo:

Parâmetros Nota:

- Data Inicial
- Data Final
- Quanto a Nota
  - Gera
  - Exclui
- Fornecedor
- Loja
- Considera Nota
  - Normal
  - Devolução/ Beneficiamento
- Aglutina Produtos
- Gera Complemento Fiscal

Valor Despesa:

- Valor Despesa
- Formulário Próprio
- Número Nota Fiscal de Despesa
- Série Nota Fiscal de Despesa
- Codigo Fornecedor Nota Fiscal de Despesa
- Loja Nota Fiscal de Despesa
- TES Nota Fiscal de Despesa

Após informar os parâmetros são listados os registros, posicione no registro e aperte sobre a opção "Gera Despesa", exibindo os campos:

Na aba "Duplicatas" necessário informar os seguintes campos:

- Natureza
- Cond. Pagamento

Na aba "Informações DANFE" necessário informar os seguintes campos:

- Tipo CPE

## Classificação de Nota

**Obs: A rotina tem como objetivo a classificação de uma Pre Nota, aonde não teve sua TES informada, desta forma sendo direcionada ao Financeiro, Estoque após realizar essa classificação.**.

Sendo necessário abrir a aba "Duplicadas" e preencher o campo "Natureza"

## Retorno

**Obs: A rotina é relacionada a Documento de Entrada, possuindo uma opção "Retornar" responsável pela controle de devolução pelo Cliente.**

No menu de Outras Ações é possível acessar a opção "Retornar".

Informar os campos:

- Cliente
- Loja
- Data Saída
- Data Saída Até
- Motivo Saída

Caso seja exibida uma mensagem após a seleção das Notas para devolução, caso o item selecionado não possua amarração a TES amarrada a TES Saída.

---

## Autor

**Cristian Gustavo** | Consultor e desenvolvedor TOTVS Protheus

- [LinkedIn Cristian Gustavo](https://www.linkedin.com/in/cristian-gustavo-719aa71b2/)
- [GitHub Cristian Gustavo](https://github.com/crsgustav0)

---

    Desenvolvido e documentado por: Cristian Gustavo
    Data início: 17/11/2025
