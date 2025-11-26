# Entedimento inicial Módulo Compras

**Cadastro Tipo Entrada Saida (TES)**

O cadastro de Tipo Entrada Saida (TES) feitas no Protheus é feito via **"Módulo 06 - Compras"**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **MATA080.PRW** e suas informações podem ser encontradas na tabela **"Tipo Entrada Saida (TES) - SF4"**.

[SF4 - Tipos de Entrada e Saida (TES) | ERP Labs](https://erplabs.com.br/SF4)

Rotina Protheus:

![alt text](src/MATA080.png)

**Obs: Como estamos tratando do Módulo de Compras, focaremos somente no Tipo de Entrada.**

---

Acesso a rotina de cadastro de Tipo Entrada e Saída (TES) via Módulo Compras:

![alt text](src/AcessoTipoTES_Compras.png)

A rotina padrão de Tipo Entrada Saida (TES) contém as seguintes operações, sendo:

- **Inclusão**
- **Alteração**
- **Consulta**
- **Exclusão**

Em caso de inclusão, deve seguir a regra de preenchimento dos campos obrigatórios, identificados com o **"\*"** em sua descrição.

![alt text](src/CamposCadastroTipoTES_Compras.png)

No menu Outras Ações, é possível encontrar as seguintes opções, sendo:

- **Copiar TES**: Realizar uma cópia da TES.

![alt text](src/CopiarTES-CadastroTipoTES_Compras.png)

---

## Aba "Adm/Fin/Custo"

- **Código do Tipo**

Define o Tipo de Entrada, o código define se o tipo é **"Entrada"** ou **"Saída"**.

Obs: Todos os código entre o intervalo de **"001"** até **"630"** se trata de Tipo Entrada.

![alt text](src/CampoCodigoTipo-CondPagamento_Compras.png)

- **Gera Duplicidade**

Define se a TES cadastrada ao ser informada na **Nota de Entrada se irá gerar Titulos a Pagar no Módulo Financeiro, fazendo a integração.**

![alt text](src/CampoGeraDupl-CondPagamento_Compras.png)

- **Atualiza Estoque**

Conceito semelhante ao campo **Gera Duplicidade** aonde, ao informar define se fará o controle, geração de estoque.

![alt text](src/CampoGeraDupl-CondPagamento_Compras.png)

- **Tes Devolução**

Em caso de uma TES de Venda, pode ser feita a amarração com a TES de Saída.

![alt text](src/TesDevol-CondPagamento_Compras.png)

- **Qtd Zerada**

Se tratando de Notas de Complemento, como Frete, Preço, Importação que são notas que tratam custos mas não quantidades, então deve permitir quantidade zerada.

![alt text](src/QtdZerada-CondPagamento_Compras.png)

- **Custo Devolução**

Em Notas de Entrada de Devolução, faz a atualização do Custo.

![alt text](src/CustoDev-CondPagamento_Compras.png)

- **Transf. Filial**

Em caso da utilização da TES para transferência de Filiais, deve informar como **"Sim"**.

![alt text](src/TransFilial-CondPagamento_Compras.png)

- **Desmembra IT Ativo Fixo**

Em caso da utilização da TES que atualiza o Ativo, deve ser informado como **"Sim"**.

**Obs: Pergunta funciona em conjunto com o retorno do campo "Atualiza Ativo"**

![alt text](src/DesmITATF-CondPagamento_Compras.png)

![alt text](src/AtualizaAtivo-CondPagamento_Compras.png)

- **Entrega Futura**

Caso se trate de uma TES com entrega futura é necessário deterinar entre as opções:

- **Recebimento de Compra com Entrega Futura**: Gera duplicata mas não gera estoque.
- **Recebimento da Entrega de Compra com Entrega Futura**: Recebe itens para estoque mas não gera duplicata.

![alt text](src/EntregaFutura-CondPagamento_Compras.png)

- **Trans. Fil. CQ**

Caso seja feita a transferência entre as Filial e utilizado o Controle de Qualidade, informa se a transferência ira para o Armazem de Controle de Qualidade.

![alt text](src/TransFilCQ-CondPagamento_Compras.png)

## Aba "Impostos"

- **Calcula ICMS**

Necessário para o cálculo correto referente a tributação, informar como **"Sim"**.

![alt text](src/CalculaICMS-CondPagamento_Compras.png)

- **Calcula IPI**

Determina se fará o cálculo IPI.

![alt text](src/CalculaIPI-CondPagamento_Compras.png)

- **Código Fiscal**

Defina a CFOPE de Entrada.

![alt text](src/CodigoFiscal-CondPagamento_Compras.png)

- **Livro Fiscal ICMS**

Defina a CFOPE de Entrada.

![alt text](src/LFiscalICMS-CondPagamento_Compras.png)

**Obs: A mesma regra se aplica para o campo "Livro Fiscal IPI".**

![alt text](src/LFiscalIPI-CondPagamento_Compras.png)

- **Destaca IPI**

Defina se destacará o IPI.

![alt text](src/DestacaIPI-CondPagamento_Compras.png)

- **IPI na Base**

Defina se há cálculo.

![alt text](src/IPIBase-CondPagamento_Compras.png)

- **Cálculo Diferença ICM**

Defina se há cálculo, geralmente usado em Material de Consumo.

![alt text](src/DifCalculoICM-CondPagamento_Compras.png)

- **PIS/COFINS**

Defina se irá considerár o PIS/COFINS.

![alt text](src/ConsPISCOFINS-CondPagamento_Compras.png)

- **Cred. PIS/COFINS**

Defina se irá a regra para o cálculo do PIS/COFINS.

![alt text](src/CalcPISCOFINS-CondPagamento_Compras.png)

- **Agrega Valor**

Determina como será feito o cálculo do Custo baseando-se no ICMS.

![alt text](src/AgregaValor-CondPagamento_Compras.png)

![alt text](src/AgregaValor2-CondPagamento_Compras.png)

**Obs: Caso o Tipo de Entrada seja de Serviço, há campos que devem ser informados como:**

- **Cálculo ISS**: Imposto sobre serviços.
  ![alt text](src/CalculoISS-CondPagamento_Compras.png)

- **Livro Fiscal ISS**:
  ![alt text](src/LivFiscalISS-CondPagamento_Compras.png)

- **Material de Consumo**:
  ![alt text](src/MaterialConsumo-CondPagamento_Compras.png)

---

## Autor

**Cristian Gustavo** | Consultor e desenvolvedor TOTVS Protheus

- [LinkedIn Cristian Gustavo](https://www.linkedin.com/in/cristian-gustavo-719aa71b2/)
- [GitHub Cristian Gustavo](https://github.com/crsgustav0)

---

    Desenvolvido e documentado por: Cristian Gustavo
    Data início: 17/11/2025
