# Web Service TLPP - Clientes (SA1)

## Contexto no portfólio

Este módulo foi incluído no portfólio como estudo prático de desenvolvimento REST em Protheus utilizando TLPP, com foco em operações de cadastro e consulta de clientes da tabela SA1. Ele representa um exemplo de camada de integração que conecta a regra de negócio do Protheus com um endpoint exposto em formato JSON, seguindo uma abordagem mais organizada e reutilizável do que rotinas isoladas.

A estrutura do fonte foi pensada para demonstrar a aplicação de boas práticas no ecossistema TOTVS:

- separação clara entre controller, serviço e modelos
- leitura direta e otimizada com SQL embutido
- gravação e validação via modelo nativo do Protheus (`CRMA980`)
- tratamento de parâmetros e regras de filial em ambiente de clientes
- exposição de API REST para consumo por frontends ou integrações externas

Esse novo fonte complementa o conjunto de projetos do repositório, que já contempla ADVPL, MVC e integração por REST, reforçando o perfil de desenvolvimento real de consultoria Protheus.

---

**Versão**: 2.0 (refatoração com MVC e SQL embutido)  
**Autor**: Cristian Gustavo  
**Última atualização**: 2026-09-10

## 🏗 Arquitetura

A solução segue uma separação de responsabilidades bem definida:

`CustomClientesController` → `ClientesService` → (`ListClientesModel` | `EditClientesModel`)

- **Controller**: gerencia as rotas HTTP, normaliza o payload e mapeia respostas em status codes REST.
- **Service**: coordena a lógica de negócio e valida entradas antes de disparar o modelo.
- **Models**:
  - **`ListClientesModel`**: leitura otimizada com `BeginSQL` para consultas de clientes.
  - **`EditClientesModel`**: escrita e validação com `FWLoadModel("CRMA980")`.

## 🚀 Endpoints

### GET `/v1/customers`
Lista clientes com paginação e filtro dinâmico.

- **Parâmetros de query**:
  - `page` (opcional, padrão: 1)
  - `pageSize` (opcional, padrão: 10)
  - `filter` (opcional, exemplo: `A1_COD = '000001'`)
  - `A1_COD` (opcional, atalho para o filtro)
- **Sucesso**: `200 OK` com lista de clientes.

### POST `/v1/customers`
Cria um cliente.

- **Payload**: objeto JSON. `A1_FILIAL` é obrigatório.
- **Comportamento**:
  - `A1_FILIAL` ausente → `400 Bad Request`.
  - `A1_FILIAL` vazio (`""`) → permitido para registros legados.
- **Sucesso**: `201 Created`.

### PUT `/v1/customers`
Atualiza um cliente existente.

- **Parâmetros de query**: `A1_FILIAL`, `A1_COD` e `A1_LOJA` são obrigatórios.
- **Payload**: JSON com campos a alterar.
- **Sucesso**: `200 OK`.
- **Falha**: `404 Not Found` se o cliente não existir.

### DELETE `/v1/customers`
Exclui logicamente um cliente.

- **Parâmetros de query**: `A1_FILIAL`, `A1_COD` e `A1_LOJA` são obrigatórios.
- **Sucesso**: `200 OK`.

## ⚠️ Regras de negócio e compatibilidade com legado

### Tratamento de filial (`A1_FILIAL`)
Para suportar bases legadas em que a filial pode vir vazia, a API diferencia:

1. **Parâmetro ausente**: o campo não existe no JSON ou na query → erro `400`.
2. **Vazio explícito**: o campo é enviado como `""` → permitido.
3. **Filial ativa**: em consultas sem filial informada, o sistema usa `FwXFilial("SA1")`.

### Validação
O `EditClientesModel` usa o modelo nativo `CRMA980`, o que garante:

- validação de tamanho de campos conforme `SX3`
- checagem de obrigatoriedade via `VldData()`
- controle de chave primária e colisões pelo próprio Protheus

## 🛠 Stack técnico

- **Linguagem**: TLPP
- **Persistência**: SQL embutido (leitura) e `FWLoadModel` (gravação)
- **Modelo**: `CRMA980` (cadastro de clientes MVC)

## 📈 Checklist de validação

- [ ] POST sem `A1_FILIAL` → `400`
- [ ] POST com `A1_FILIAL=""` → `201`
- [ ] GET sem `A1_FILIAL` → usa filial ativa
- [ ] PUT/DELETE sem `A1_COD` → `400`
- [ ] PUT/DELETE com chave inexistente → `404`

---

Este fonte representa uma aplicação realista do uso de TLPP em cenários de integração no Protheus e reforça a proposta do portfólio como base de estudo, arquitetura e solução prática para personalizações TOTVS.
