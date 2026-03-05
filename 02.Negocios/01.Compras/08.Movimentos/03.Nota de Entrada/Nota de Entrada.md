# Administração Módulo Compras

**Rotina Nota de Entrada**

O cadastro de Nota de Entrada feitas no Protheus é feito via **"Módulo 06 - Compras"**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **MATA110.PRW** e suas informações podem ser encontradas na tabelas **"Tabela de Nota de Entrada - SC8"**.

[SC8 - Nota de Entrada | ERP Labs](https://erplabs.com.br/SC8)

# Gera Nota de Entrada

Rotina Protheus:

![alt text](src/MATA131.png)

**Obs: A rotina permite o registro de entrada de Mercadoria ou Serviços dentro da empresa, iniciando um processo de atualização de dados financeiros e estoque e Custos por conta de TES. Permite também a classificação e permite o lançamento dos mesmos.**.

## Parâmetros

Na tela registros é necessário posicionar sobre o registro e apertar sobre a opção "Classificar".

Necessário informar os parâmetros para retorno de dados, sendo:

- Data Emissão
- Espécie documento

Itens Documentos:

- Tipo Operação
  Caso utilize TES inteligente.
- Tipo Entrada
  Referente a TES, justamente que faz a classificação da Pré Nota.

Caso necessário informar os campos:

- Conta Contábil
- C. Custo
- Item Conta
- Ordem Produção, caso informada e caso a TES preenchida atualize o cadastro de produção será direcionada o custo para Ordem de Produção, podendo consultar retorno do campo "Consulta Padrão".
- Caso de trate de uma Importação, pode ser informado o campo "Valor I.I."
- Caso possua rateio relacionado, é possível incluir via Menu de Opções e o item "Item C.C. e informando C. Custo e % de Rateio.

Aba inferior "Duplicatas"

- Cond. de Pagamento
- Natureza
- Moeda

- Aba inferior "Totais"

Informações com totais.

- Aba inferior "Info Fornecedor/ Cliente.'"

Informações relacionadas a Fornecedor e Cliente.

- Aba inferior "Descontos/ Frete/ Despezas"

Valores relacionados a Descontos e despezas.

Após a classificação o item tem sua legenda na cor VERMELHA, sinalizando que o registro foi classificado.

Possível fazer a inclusão de Notas com tipos diferentes, sendo:

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
