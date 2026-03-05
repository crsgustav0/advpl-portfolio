# Administração Módulo Compras

**Rotina Contratos de Parceria**

O cadastro de Contratos de Parceria feitas no Protheus é feito via **"Módulo 06 - Compras"**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **MATA125.PRW** e suas informações podem ser encontradas na tabelas **"Tabela de Contratos de Parceria - SC3"**.

[SC3 - Contratos de Parceria | ERP Labs](https://erplabs.com.br/SC3)

# Gera Contratos de Parceria

Rotina Protheus:

![alt text](src/Acesso-ContratosParceria_Compras.png)

![alt text](src/MATA125.png)

**Obs: A rotina tem como objetivo o cadastro de fornecimento de Produtos, Serviços durante um período eliminando a necessidade de inclusão de Solicitações de Compras, realização de Cotações desta forma agilizando o processo de Compras.**.

## Parâmetros

Necessário informar os parâmetros para retorno de dados, sendo:

- Fornecedor
- Condição de Pagamento
- Filial de Entrega, caso de filial diferente
- Moeda

Itens:

- Produto
  Caso de uso específico para Contrato de Parceria é necessário se o campo "Contrato" está marcado como "Sim" ou "Ambos" no Cadastro de Produto.

![alt text](src/ProdutoContratoSim-ContratoParceria_Comrpas.png)

- Quantidade
- Preço Unitário
- Data Entrega
- Armazem
- C.Custo, Conta Contábil, Valor de Desconto

![alt text](src/ProdutoContratoOK-ContratoParceria_Compras.png)

## Autorização de Entrega

**Obs: A rotina tem como objetivo a aprovação de de entrega de Solicitações de Contrato de Parceria. Também é possível realizar a aprovação a partir da quantidade, funcionando como um saldo de entrega do valor total do Contrato de Parceria**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **MATA122.PRW** e suas informações podem ser encontradas na tabelas **"Tabela de Ped.Compra / Aut.Entrega - SC7"**.

[SC7 - Ped.Compra / Aut.Entrega | ERP Labs](https://erplabs.com.br/SC7)

Rotina Protheus:

![alt text](src/Acesso-AutorizacaoEntrega_Compras.png)

![alt text](src/MATA122.png)

Na tela de baixo é exibido os totais.

Necessário informar os parâmetros, sendo:

- Numero Autorização
- Data Entrega
- Fornecedor
- Condição de Pagamento

É possível via Outras Ações e sobre a opção "Contrato" aonde são exibidos todos os contratos relacionados ao Fornecedor informado.

![alt text](src/Contrato-OutrasAcoes-ContratoParceria_Comrpas.png)

![alt text](src/Contrato2-OutrasAcoes-ContratoParceria_Comrpas.png)

Possível alterar a quantidade dos itens informados, visualizando também informações amarradas a Solicitação de Compras como:

- Itens de Contrato
- Número da Solicitação de Compras

![alt text](src/CamposSC-ContratoParceria_Comrpas.png)

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
