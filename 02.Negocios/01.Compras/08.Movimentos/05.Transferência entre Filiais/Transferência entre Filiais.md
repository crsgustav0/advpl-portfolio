# Administração Módulo Compras

**Rotina Transferência entre Filiais**

O cadastro de Transferência entre Filiais feitas no Protheus é feito via **"Módulo 06 - Compras"**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **MATA110.PRW** e suas informações podem ser encontradas na tabelas **"Tabela de Transferência entre Filiais - SC8"**.

[SC8 - Transferência entre Filiais | ERP Labs](https://erplabs.com.br/SC8)

# Gera Transferência entre Filiais

Rotina Protheus:

![alt text](src/MATA131.png)

**Obs: A rotina tem o objetivo de realizar a automação da transferência de Filiais, gerando documentos como NF Saída Filial Origem, Pré Nota ou Nota Classificada na Filial Destino.**.

## Parâmetros

Necessário informar os parâmetros para retorno de dados, sendo:

Parâmetros Nota:

- Produto Inicial
- Produto Final
- Filial Inicial
- Filial Final
- Armazem Inicial
- Armazem Final
- Tipo Inicial
- Tipo Final
- Grupo Inicial
- Grupo Final
- Gera documento de entrada
  - A classificar, gerar Pré Nota
  - Classificado, gera Documento de Entrada já classificado
  - Não gerar
- Condição de Pagamento
- TES para Nota de Entrada
- Dados de Origem
  - Filial corrente
  - Todas as filiais
- Tipo Operação Entrada
- Tipo Operação Saída

Dados NF Frete:
Itens Documentos:

- Formulário Própria
- Numero Conhecimento
- Serie Conhecimento
- Fornecedor, importante a transportadora estar cadastrada como Fornecedor dessa forma podendo gerar os títulos
- Codigo TES
- Valor Conhecimento
- UF Origem
- Aglutinar produtos

Caso necessário informar os campos:

- Base ISMS Retido
- Valor ISMS Retido
- Especia

Obs: Importante ressaltar que o Transferência entre Filiais são cadastrados apenas Notas de Entrada, Devolução, Beneficiamento que possuam TIPO "FOB" entrando no Custo do Produto. Caso possua tipo "FIB".

Após informar os parâmetros são listados os registros, posicione no registro e aperte sobre a opção "Gera Conhecimento", exibindo os campos:

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
