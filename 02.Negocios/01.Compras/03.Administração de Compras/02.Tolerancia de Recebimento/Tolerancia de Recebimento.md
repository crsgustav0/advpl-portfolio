# Administração Módulo Compras

**Rotina Tolerância de Recebimento**

O cadastro de Tolerância de Recebimento feitas no Protheus é feito via **"Módulo 06 - Compras"**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **COMA020.PRX** e suas informações podem ser encontradas na tabelas **"Tolerância de Recebimento na Entrada Material- AIC"**.

**Obs: A rotina tem como funcionalidade o cadastro de regras da tolerência para materiais com o objetivo de validar as entregas realizadas pelo Fornecedor sendo Preço, Quantidade, Validade em decardo com o Pedido. Ou seja em caso de desacordo com a tolerância de recebimento define a data ou quantidade para possível aprovação.**

[AIC - Tolerância de Recebimento na Entrada Material | ERP Labs](https://erplabs.com.br/AIC)

Rotina Protheus:

![alt text](src/COMA020.png)

Acesso a rotina de cadastro de Tolerância de Recebimento via Módulo Compras:

![alt text](src/Acesso-ToleranciadeRecebimento_Compras.png)

A rotina padrão de Tolerância de Recebimento contém as seguintes operações, sendo:

- **Inclusão**
- **Alteração**
- **Consulta**
- **Exclusão**

Em caso de inclusão, deve seguir a regra de preenchimento dos campos obrigatórios, identificados com o **"/"** em sua descrição.

![alt text](src/Campos-ToleranciadeRecebimento_Compras.png)

## Observações

- **Fornecedor**

Caso a tabela de preço possua uma condição de pagamento **específica** deve ser informada, **caso contrário o campo deve ser deixado em branco.**

![alt text](src/CampoFornecedor-AdmTabPreço_Compras.png)

**Obs: A mesma regra se aplica ao campo "Produto" e Grupo.**

![alt text](src/CampoProduto-AdmTabPreço_Compras.png)

![alt text](src/CampoGrupo-AdmTabPreço_Compras.png)

Ao informar os campos "Quantidade" e "Preço" indica que caso a Nota de Entrada possa dar entrada sem a necessidade de liberação.
**Ao informar o campo é definido que em caso de aumento na quantidade ou preço as diferenças serão toleradas.**
![alt text](src/CampoQuantidade-AdmTabPreço_Compras.png)

![alt text](src/CampoPreco-AdmTabPreço_Compras.png)

---

## Autor

**Cristian Gustavo** | Consultor e desenvolvedor TOTVS Protheus

- [LinkedIn Cristian Gustavo](https://www.linkedin.com/in/cristian-gustavo-719aa71b2/)
- [GitHub Cristian Gustavo](https://github.com/crsgustav0)

---

    Desenvolvido e documentado por: Cristian Gustavo
    Data início: 17/11/2025
