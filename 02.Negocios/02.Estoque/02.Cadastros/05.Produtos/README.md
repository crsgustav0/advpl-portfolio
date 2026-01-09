# Entedimento inicial Módulo Estoque/Custos

**Cadastro Produtos**

O cadastro de Produtos feitas no Protheus é feito via **"Módulo 04 - Estoque/Custos"**.

De forma mais técnica, as informações cadastradas no Protheus é feita pela rotina padrão **MATA010.PRW** e suas informações podem ser encontradas na tabela **"Descrição Genérica do Produto - SB1"**.

**Obs: A rotina tem como objetivo o cadastro, controle de informações relacionadas aos produtos e serviços adquiridos, fornecidos fabricados ou fornecidos pela empresa**.

[SB1 - Descrição Genérica do Produto | ERP Labs](https://erplabs.com.br/SB1)

Rotina Protheus:

![alt text](src/MATA010.png)

![alt text](src/Acesso-Produtos-EstoqueCustos.png)

---

A rotina padrão de Produtos contém as seguintes operações, sendo:

- **Inclusão**
- **Alteração**
- **Consulta**
- **Exclusão**

Em caso de inclusão, deve seguir a regra de preenchimento dos campos obrigatórios, identificados com o **"/"** em sua descrição.

![alt text](src/CamposProdutos-EstoqueCustos.png)

### Observações

- **Alternativo**

Referente ao produto alternativo, sendo substuído em uma Ordem de Produção ou Solic. de Compra, sendo um campo opcional.

![alt text](src/Alterativo-ProdutosCampo-EstoqueCustos.png)

# Aba "Cadastrais"

- **Conta Contábil**

Caso informado para amarrações com a Conta Contabil a partir desse produto.

![alt text](src/ContaContabil-ProdutosCampo-EstoqueCustos.png)

A mesma regra se aplica para os campos:

- **Centro Custo**

![alt text](src/CCusto-ProdutosCampo-EstoqueCustos.png)

- **Item Conta**

![alt text](src/ItemConta-ProdutosCampo-EstoqueCustos.png)

- **Item Conta**

![alt text](src/ItemConta-ProdutosCampo-EstoqueCustos.png)

- **Familia**: Define se o produto faz parte de uma família de produtos.

![alt text](src/Familia-ProdutosCampo-EstoqueCustos.png)

- **Base Estrutura**: Define se será feito a regra de 3 no cálculo.

![alt text](src/Familia-ProdutosCampo-EstoqueCustos.png)

- **Apropriação**: Define se a apropriação do produto com base no seu empenho, estrutura:
  - **Direta:** Uso de material que pode ser quantificado como exemplo a estrutura de 50 palets que são montados a partir de tábuas de madeiras.
  - **Indireta:** Apropriação em caso de produtos não mensuráveis na finalização do produto, como exemplo, o gasto de tinta para a pintura de um produto.

![alt text](src/Apropriacao-ProdutosCampo-EstoqueCustos.png)

- **Fantasma**: Define se o produto agrega a outros produtos sem gerar custo na ordem de produção.

![alt text](src/Fantasma-ProdutosCampo-EstoqueCustos.png)

- **Rastro**: Define se o produto irá controlar sendo:
  - **S:** Sublote
  - **L:** Lote
  - **N:** Não Utiliza

![alt text](src/Rastro-ProdutosCampo-EstoqueCustos.png)

- **Perman. Inventário**: Define se a quantidade de dias que o produto é "inventariado", feito seu inventário, contabilização.

![alt text](src/PermanInventario-ProdutosCampo-EstoqueCustos.png)

- **Cod Barras e Cod GTIN**: Caso possua controle de Cod. Barras e Cod. GTIN, campos utilizados pelo módulo SIGAACD - Automação e Coleta de Dados.

![alt text](src/CodBarras-ProdutosCampo-EstoqueCustos.png)

- **Cod Form. Lote**: Define caso o produto tenha o controle do lote.

![alt text](src/CodFormLote-ProdutosCampo-EstoqueCustos.png)

- **Cod Endereçamento**: Define caso o produto tenha o controle do endereçamento.

![alt text](src/ControleEndereçamento-ProdutosCampo-EstoqueCustos.png)

- **Custeio OP**: Define se o produto quando empenhado, solicitado para ordem de produção irá permitir o custeio zero desse produto, sendo:
  - **Permite**: Custeio zero.
  - **Não Permite**: Deve ser informado em toda solicitação for solicitado seu custo é direcionado a Produção.

![alt text](src/CusteioOP-ProdutosCampo-EstoqueCustos.png)

- **Valida Num. Série**: Define qual unidade de medida do produto deve ser considerada para a validade de número de série, sendo:
  - **1ª UN. Medida**
  - **2ª UN. Medida**

![alt text](src/VldNumLote-ProdutosCampo-EstoqueCustos.png)

- **Classe Valor**: Campo opcional, caso a empresa utilize e deseja controlar o controle a classe da valor via Cadastro do Produto.

![alt text](src/ClasseValor-ProdutosCampo-EstoqueCustos.png)

- **Considera Potencia**: Campo opcional que para ser considerado, **o campo "Rastreabilidade Produto" deve obrigatóriamente estar informado como "Sim"** e utilizando o campo auxiliar **"Potencia Padrão"**.

![alt text](src/ConsideraPotencia-ProdutosCampo-EstoqueCustos.png)

![alt text](src/ConsideraPotencia2-ProdutosCampo-EstoqueCustos.png)

![alt text](src/ConsideraPotencia3-ProdutosCampo-EstoqueCustos.png)

- **FEFO**: Campo opcional, caso a empresa utilize e deseja controlar o controle a classe da valor via Cadastro do Produto.

# Aba "MRP Suprimentos"

Cadastro responsável pela geração do MRP e possíveis solicitações de compras.

- **Qtd. Embalagem**: Campo referente a quantidade embalagem.

![alt text](src/QtdEmbalagem-ProdutosCampo-EstoqueCustos.png)

- **Qtd. Pedido**: Campo referente a quantidade pedido, atingindo a quantidade informada será disparada uma solicitação com o valor informado no campo **Qtd. Embalagem**.

![alt text](src/QtdPedido-ProdutosCampo-EstoqueCustos.png)

- **Segurança**: Campo referente a quantidade segurança do estoque referente a esse produto.

![alt text](src/Seguranca-ProdutosCampo-EstoqueCustos.png)

- **Entrega**: Campo referente a quantidade de dias para a entrega do produto, funciona em conjunto com o campo **Tipo Prazo**, informando se será considerado em Horas, Dias, Meses ou Anos.

![alt text](src/Entrega-ProdutosCampo-EstoqueCustos.png)

Campo **Tipo Prazo**:
![alt text](src/TipoPrazoEntrega-ProdutosCampo-EstoqueCustos.png)

- **Lote Economico**: Campo referente a quantidade a ser comprada do produto, total ou mínima, ou também informar a mesma quantidade do campo **Qtd. Embalagem**. A mesma regra pode ser aplicada ao campo **Lote Mínimo**.

![alt text](src/LoteEconomico-ProdutosCampo-EstoqueCustos.png)

Campo **Lote Mínimo**:
![alt text](src/LoteMinimo-ProdutosCampo-EstoqueCustos.png)

- **Tolerância**: Campo referente a quantidade de dias da tolerância para o recebimento do produto, **considerando o valor como porcentagem**.

![alt text](src/Tolerancia-ProdutosCampo-EstoqueCustos.png)

**As informações anteriores podem ser utilizados em Solic. de Compras para Produtos Comprados ou Produzidos aonde é informado nos campos**:

- **Tipo Dec. OP**: Campo referente ao tratamento do decimal para a estrutura do produto, sendo:
  - **N = Tratamento Normal**
  - **A = Arredonda**
  - **I = Incrementa**
  - **T = Tratamento sem decimais, trunca as casas decimais**

![alt text](src/TipoDecOP-ProdutosCampo-EstoqueCustos.png)

- **Entra MRP**: Campo que define se será feito o cálculo do MRP.

![alt text](src/EntraMRP-ProdutosCampo-EstoqueCustos.png)

- **Prazo Validade**: Campo referente ao prazo de validade em dias do produto, sendo usado para cálculo da data de validade do lote do produtos.

![alt text](src/EntraMRP-ProdutosCampo-EstoqueCustos.png)

- **Prazo Validade**: Campo referente ao prazo de validade em dias do produto, sendo usado para cálculo da data de validade do lote do produtos.

- **Roteiro Operação Padrão**: Campo utilizado para fazer a amarração do Roteiro de Operação, informado caso a empresa utilize o **Módulo PCP (Planejamento e Controle de Produção)**.

![alt text](src/RoteiroOpPadrão-ProdutosCampo-EstoqueCustos.png)

- **Estoque Máximo**: Campo que define a quantidade máxima para o estoque, armazenamento do produto.

![alt text](src/EstoqueMaximo-ProdutosCampo-EstoqueCustos.png)

Em caso de subproduto os seguintes campos podem ser informados:

- **Atende Necessidade**: Caso o produto se trate de um subproduto em estruturas, indicando se deve ser produzido sua estrutura origem ou comprada.

![alt text](src/AtendNec-ProdutosCampo-EstoqueCustos.png)

- **Lote Subproduto**: Campo que indica a quantidade do lote para gerar os subproduto.

![alt text](src/LoteSubProduto-ProdutosCampo-EstoqueCustos.png)

- **Estoque Origem**: Campo que indica a estrutura para geração de saldos.

![alt text](src/EstoqueOrigem-ProdutosCampo-EstoqueCustos.png)

# Aba "C.Q (Controle de Qualidade)"

Cadastro que permite a inspeção e avaliação de produtos via Almoxarifado e caso a empresa faça o uso do Módulo de Controle de Qualidade.

- **Nota Minima**: Campo que indica a nota mínima do Controle de Qualidade para o produto.

![alt text](src/NotaMinima-ProdutosCampo-EstoqueCustos.png)

- **Tipo Controle de Qualiade**: Campo que indica o tipo de controle de qualidade para produto, sendo:

  - **M - Materiais**, Materiais sendo no Módulo Estoque/ Custos.
  - **Q - SigaQuality**, Módulo Controle de Qualidade.

![alt text](src/NotaMinima-ProdutosCampo-EstoqueCustos.png)

- **Produções C.Q**: Campo que indica o intervalo de produções do produto que será deixado no armazém para o Controle de Qualidade para avaliação.

![alt text](src/ProducoesCQ-ProdutosCampo-EstoqueCustos.png)

- **Nome Científico Produto**: Campo obrigatório para a inclusão de um novo produto.

![alt text](src/NomeCient-ProdutosCampo-EstoqueCustos.png)

### Observações

É realizado também o cadastro de produtos que não necessariamente são insumos, sendo apontados em Ordem de Produção como:

- Mão de Obra
- Gastos gerais de Produção

Sendo feito com o preenchimento do campo **Código** com o "MOD" e seu **Centro de Custo**, sendo preenchido desta forma:

- **Código**: "MOD001"
  Nesse exemplo está sendo feito o cadastro de Mão de Obra para um determinado C. Custo.
- **Tipo**: "MO", referente a Mão de Obra.
- **Unidade**: "HR", referente a Hora.
- **Arm. Padrão**: "01", referente ao Armazém Padrão.
- **C. Custo**: "001", referente ao C. Custo Padrão e também usado na composição do campo "Código".

  ![alt text](src/MOD001-ProdutosCampo-EstoqueCustos.png)

Também é possível fazer a inclusão da Mão de Obra sem informar o valor "MOD" no campo **"Código"**.

- **Código**: "00000201"
  Nesse exemplo está sendo feito o cadastro de Mão de Obra para um determinado C. Custo.
- **Tipo**: "GG", referente a Gastos Gerais.
- **Unidade**: "HR", referente a Hora.
- **Arm. Padrão**: "01", referente ao Armazém Padrão.
- **C. Custo**: Informado na aba **Outros**.

![alt text](src/MOD002-ProdutosCampo-EstoqueCustos.png)

Na aba outros será informado o campo **"C. Custo p/ Custo"**, podendo também informar o campo **"Grupo Cont. Custo"** referente ao Grupo Contábil de Custo.

![alt text](src/C.CustoPCustoOutros-ProdutosCampo-EstoqueCustos.png)

![alt text](src/GrupoContabilC.CustoPCustoOutros-ProdutosCampo-EstoqueCustos.png)

---

## Autor

**Cristian Gustavo** | Consultor e desenvolvedor TOTVS Protheus

- [LinkedIn Cristian Gustavo](https://www.linkedin.com/in/cristian-gustavo-719aa71b2/)
- [GitHub Cristian Gustavo](https://github.com/crsgustav0)

---

    Desenvolvido e documentado por: Cristian Gustavo
    Data início: 17/11/2025
