# Administração Módulo Compras

**Rotina Grupo de Aprovação**

O cadastro de Grupo de Aprovação feitas no Protheus é feito via **"Módulo 06 - Compras"**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **MATA114.PRW** e suas informações podem ser encontradas na tabelas **"Tabela de Grupo de Aprovação - SAL"**.

**Obs: A rotina tem como objetivo a associação de os aprovadores conforme a hierarquia definida**.

[SAL - Grupo de Aprovação | ERP Labs](https://erplabs.com.br/SAL)

Rotina Protheus:

![alt text](src/MATA114.png)

Acesso a rotina de cadastro de Grupo de Aprovação via Módulo Compras:

![alt text](<src/Acesso-Grupo de Aprovação_Compras.png>)

A rotina padrão de Grupo de Aprovação contém as seguintes operações, sendo:

- **Inclusão**
- **Alteração**
- **Consulta**
- **Exclusão**

Em caso de inclusão, deve seguir a regra de preenchimento dos campos obrigatórios, identificados com o **"/"** em sua descrição.

![alt text](<src/Campos-Grupo de Aprovação_Compras.png>)

---

## Grupo de Aprovadores

- **Aprovador**

Define o aprovador.

![alt text](src/CampoAprovador-GrupoAprovadores_Compras.png)

- **Perfil Aprovador**

Define o perfil aprovador.

![alt text](src/CampoPerfilAprovador-GrupoAprovadores_Compras.png)

- **Nível**

Define o nível do aprovador.

![alt text](src/CampoNivel-GrupoAprovadores_Compras.png)

- **Superior**

Define o superior.

![alt text](src/CampoSuperior-GrupoAprovadores_Compras.png)

Definição segundo superior:

![alt text](src/CampoSuperior2-GrupoAprovadores_Compras.png)

- **Definição de Superior**

Feito a definição do superior responsável, é necessário seguir as etapas, sendo:

- **Aprovação Jr**: Realiza a primeira aprovação.
- **Aprovação Master**: Realiza a segunda, desta forma encaminhando Alçadas.

![alt text](src/ExpSuperior-GrupoAprovadores_Compras.png)

**Obs: Caso os dois usuários possuam os mesmos níveis, os dois realizarão as aprovações, desta forma aprovando o Pedido de Compra, Solic. de Compras, entre outros.**

![alt text](src/ExpSuperior2-GrupoAprovadores_Compras.png)

## Tipo Compra x Aprovadores

- **Tipo Compra**

Define o tipo de compra por aprovador.

![alt text](src/CampoTipoCompra-GrupoAprovadores_Compras.png)

## Autor

**Cristian Gustavo** | Consultor e desenvolvedor TOTVS Protheus

- [LinkedIn Cristian Gustavo](https://www.linkedin.com/in/cristian-gustavo-719aa71b2/)
- [GitHub Cristian Gustavo](https://github.com/crsgustav0)

---

    Desenvolvido e documentado por: Cristian Gustavo
    Data início: 17/11/2025
