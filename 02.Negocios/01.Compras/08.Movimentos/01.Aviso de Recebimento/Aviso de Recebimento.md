# Administração Módulo Compras

**Rotina Aviso de Recebimento**

O cadastro de Aviso de Recebimento feitas no Protheus é feito via **"Módulo 06 - Compras"**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **MATA110.PRW** e suas informações podem ser encontradas na tabelas **"Tabela de Aviso de Recebimento - SC8"**.

[SC8 - Aviso de Recebimento | ERP Labs](https://erplabs.com.br/SC8)

# Gera Aviso de Recebimento

Rotina Protheus:

![alt text](src/MATA131.png)

**Obs: A rotina tem a finalidade de informar a carga de um veículo podendo se tratar de Nota Fiscal, várias Notas Fiscais de um ou mais Fornecedores.**.

## Parâmetros

Necessário informar os parâmetros para retorno de dados, sendo:

- Numero Aviso
- Data emissão
- Tipo (Cliente ou Fornecedor)
- Código (Cliente ou Fornecedor)
- Loja
- Tipo Nota
- Numero Documento
- Data e Horário Entrega
- Identificação veículo (Placa)

Itens Documentos:
Informar as Notas Fiscais que fazem parte dessa entrega.

- Numero NF
- Serie
- Data emissão
- Tipo (Cliente ou Fornecedor)
- Código (Cliente ou Fornecedor)
- Loja
- Valores ICM
- Peso
- Volume
- Tipo Documento, em caso de DANFEE informar como SPED
- C.Custo, Conta Contábil, Valor de Desconto

Durante o processo de informe dos Produtos, caso o item se relaciona com Pedidos, pode ser informado via Menu de Opções via item "Pedidos" sendo necessário selecionar o Pedido desejado. 

Para homologar, autorizar o Aviso de Recebimento, é necessário selecionar na tela de Menu a opção "Homologar", lembrando que caso os itens informados forem amarrados ao Tipo de Entrada, podendo ser Pedidos ou Produtos, será gerado uma Nota de Entrada já classificada.

Caso as Notas não possuem TES informado será gerado uma pré nota no cadastro de Pré Nota para classificação e informe da Condição de Pagamento e TES.

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
