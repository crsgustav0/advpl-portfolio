# Administração Módulo Compras

**Rotina Pre Nota de Entrada**

O cadastro de Pre Nota de Entrada feitas no Protheus é feito via **"Módulo 06 - Compras"**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **MATA110.PRW** e suas informações podem ser encontradas na tabelas **"Tabela de Pre Nota de Entrada - SC8"**.

[SC8 - Pre Nota de Entrada | ERP Labs](https://erplabs.com.br/SC8)

# Gera Pre Nota de Entrada

Rotina Protheus:

![alt text](src/MATA131.png)

**Obs: A rotina se trata de uma rotina que contém os cadastros básicos de forma prévia do documento fiscal que será recebido pela empresa, tendo a finalidade de agilizar o processo de recebimento de materiais registrados via Documento de Entrada.**.

## Parâmetros

Na tela registros como verdes estão como Documento não Classificado.
Vermelho documentos normais, que já foram classificados.

Necessário informar os parâmetros para retorno de dados, sendo:

- Tipo de Nota
- Numero Pre Nota
- Serie
- Data emissão
- Fornecedor
- Espécie documento
- UF. Origem    
- Tipo Nota
- Numero Documento
- Data e Horário Entrega
- Identificação veículo (Placa)

Itens Documentos:
Informar as Notas Fiscais que fazem parte dessa entrega.

- Produto
- Unidade 
- Quantidade
- Valor Unitário
- Valor Total
- Não será informado Vlr. IPI, ICMS 

Caso necessário informar os campos:
- Conta Contábil
- C. Custo
- Item Conta    

Durante o processo de informe dos Produtos, caso o item se relaciona com Pedidos, pode ser informado via Menu de Opções via item "Pedidos" sendo necessário selecionar o Pedido desejado. 

## Autorização de Entrega

**Obs: A rotina tem como objetivo a aprovação de de entrega de Solicitações de Contrato de Parceria. Também é possível realizar a aprovação a partir da quantidade, funcionando como um saldo de entrega do valor total do Contrato de Parceria**.

Na tela de baixo é exibido os totais.

Necessário informar os parâmetros, sendo:

- Numero Autorização
- Data Entrega
- Fornecedor
- Condição de Pagamento

É possível via Outras Ações e sobre a opção "Contrato" aonde são exibidos todos os contratos relacionados ao Fornecedor informado.

Possível alterar a quantidade dos itens informados, visualizando também informações amarradas a Solicitação de Compras como:

- itens de Contrato
- Número da Solicitação de Compras

## Liberação de Documentos

**Obs: A rotina é relacionada a Alçada de Aprovação, utilizada para aprovação de documentos.**.

Ao abrir a tela é exibida a mensagem que o usuário necessita de estar cadastrado como aprovado.

Registros sinalizados com a legenda vermelha estão como Pendencia de Aprovação pelo Usuário.

Caso o limite de aprovação do usuário seja menor que o limite do item da rotina de Aprovações é necessário alterar o limite do cadastro do usuário na tela de Aprovadores.

No menu de Outras Ações é possível também rejeitar a Aprovação.

---

## Autor

**Cristian Gustavo** | Consultor e desenvolvedor TOTVS Protheus

- [LinkedIn Cristian Gustavo](https://www.linkedin.com/in/cristian-gustavo-719aa71b2/)
- [GitHub Cristian Gustavo](https://github.com/crsgustav0)

---

    Desenvolvido e documentado por: Cristian Gustavo
    Data início: 17/11/2025
