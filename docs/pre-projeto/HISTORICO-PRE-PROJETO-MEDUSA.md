# HISTÓRICO PRÉ-PROJETO — MEDUSA (Período: mediados de agosto → outubro de 2026)

> **Documento de referência histórica.** Consolida todo o material do diretório
> `Y:\Machine Learning\medusa\` (espelho dos trabalhos executados em
> `C:\AI\JURIDICO-AI`, máquina **IA-SERVER**) que precedeu o atual **projeto-medusa**.
> Objetivo: servir de base para DevOps/engineers futuros — hardware real, versões,
> configurações funcionais, decisões e lições aprendidas.

---

## 1. Contexto e objetivo do pré-projeto

Entre **13 e 18/08/2026**, um projeto chamado internamente de **"Pacote Jurídico Local" / JURIDICO-AI**
(e referido como *medusa* nos planos do DeepSeek) foi concebido e implantado:

- **Meta:** montar um ambiente de IA **100% local** (nenhum dado sai do escritório) para fluxo jurídico:
  ingestão de documentos → OCR → classificação → entidades → RAG → análise → estratégia → redação → auditorias → DOCX → **revisão humana obrigatória**.
- **Método de trabalho:** prompts a múltiplas IAs (ChatGPT, Claude, DeepSeek, Gemini, Perplexity, Qwen),
  com todos os artefatos salvos em subpastas nomeadas pelo domínio de cada IA — hoje espelhados em `Y:\Machine Learning\medusa\`.
- **Regra de segurança central (vigente desde a v1.0):**
  *"Nenhuma peça chega a RELEASED sem revisão humana"* (gate no `state-machine.json`).
- **Consequência no projeto atual:** o projeto-medusa é a evolução dessa base; os guias, diagnósticos
  e scripts descritos abaixo são o "mapa fundacional".

---

## 2. Cronologia reconstruída (com evidência em arquivo)

| Data (2026) | Evento | Evidência |
|---|---|---|
| 13–15/08 | Concepção da arquitetura e redação do GUIA-JURIDICO-LOCAL (v1.0) — guia mestra com seções até a nº 31 | `chatgpt.com/Pacote-Juridico-Local-v1.0/GUIA-JURIDICO-LOCAL.md` |
| **14/08 17:13** | Container **ollama** criado (primeiro serviço do compose) | `DIAGNOSTICO-JURIDICO-v1/07-CONTAINERS.txt` |
| **15/08** | Modelos baixados no Ollama (qwen3:30b, gpt-oss:20b, deepseek-r1:32b, nomic-embed-text) | qwen `12-OLLAMA-MODELOS.txt` ("2 days ago" em 17/08) |
| **16/08 12:28** | Container **open-webui** criado | `07-CONTAINERS.txt` |
| **16/08 13:51** | Container **docling** (docling-serve) criado — OCR fora do Open WebUI | `07-CONTAINERS.txt` |
| 16/08 | Empacotamento da v1.2 (`MANIFEST.json` datado de 2026-08-16) | `MANIFEST.json`, `Pacote-Juridico-Local-v1.2.zip` |
| **17/08 15:19** | Diagnóstico **somente leitura** v1/v1.0.1 rodado na máquina | pasta `DIAGNOSTICO-JURIDICO-v1/` (24 txt) |
| 17/08 | Scripts de auditoria via DeepSeek gerados (3 variantes) | `deepseek.com/*.ps1` (20260817) |
| **17/08 16:35** | Diagnóstico dirigido **v2** (Qwen) com 5 perguntas técnicas → todas `[PASS]` | pasta `qwen.ai/DIAGNOSTICO-JURIDICO-v2_2026-08-17_163514/` |
| 17/08 | Perplexity avalia o guia e propõe 16 seções novas de governança (32–47) → **v1.1** | `perplexity.ai/pode implementar ….md`, `claude.ai/GUIA-...-ADENDO.zip` |
| 17/08 | Plano de implementação tático semanal (DeepSeek) — 4 fases, VRAM e agentes | `deepseek.com/Plano de Implementação Tático_medusa_deepseek.md` |
| 19–20/08 | Benchmark Docling vs. Kreuzberg (estudo de OCR) | `deepseek.com/Docling vs. Kreuzberg.pdf` |
| 17/09/2026 | Kit visual do projeto ("projeto-medusa e davy-jones") — imagem `ChatGPT Image 19 de set…` | `C:\Intel\medusa\projeto-medusa_e_davy-jones_17092026\png\` |
| out/2026 | **projeto-medusa** (repositório atual) — fase de documentação/README | Sessões atuais (OpenCode) |

> **Leitura do ciclo:** ≈ 4 dias úteis para conceber, implantar, auditar com 3 IAs diferentes
> e evoluir a documentação da v1.0 → v1.1 → v1.2. Tempo de trabalho estimado: ~30–40 h.

---

## 3. Hardware real (auditado, não estimado)

**Máquina:** `IA-SERVER` · placa-mãe ASUS · Windows Pro (build 26200, reportado como Windows 10 Pro/11 Pro conforme a ferramenta)

| Componente | Especificação | Fonte |
|---|---|---|
| CPU | AMD Ryzen 9 **9950X3D**, 16 núcleos / 32 threads, 4,3 GHz base | `02-CPU-RAM.txt` |
| RAM | 32 GB Corsair (2×16 GB) CMK32GX5M2B6000C38, **rodando a 4800 MT/s** (stick "6000") | `02-CPU-RAM.txt` |
| GPU | NVIDIA **GeForce RTX 5090** — 32.607 MiB; driver 610.88; CUDA UMD 13.3; idle 3,5 GB usados | `03-NVIDIA.txt` |
| Disco | 1× NTFS (C:) ~999 GB, ~64 GB livres | `21-DISCOS.txt` |
| Rede | Realtek 2,5 GbE; Hyper-V vSwitch (WSL); DNS manual 1.1.1.1/8.8.8.8 | `20-REDE.txt` |
| Ferramentas host | Python 3.14.7 · pip 26.2.1 · Git 2.55.0 · Node 26.7.0 · npm 11.19.0 | `22-FERRAMENTAS.txt` |

⚠️ Detalhes que costumam morder:
- A v1.0/guia fala em **9950X**, mas a máquina real é **9950X3D** — usar os valores auditados.
- RAM XMP: módulos 6000 MT/s travados em **4800** — considerar tunar no BIOS se workload recomprimir.

---

## 4. Stack de software e versões (17/08/2026)

| Camada | Versão |
|---|---|
| Docker Desktop | **4.86.0** (236216) |
| Docker Engine | 29.7.2 (API 1.55) |
| containerd | v2.2.5 · runc 1.3.6 |
| Docker Compose | **v5.3.1** |
| WSL | 2.7.11.0 · kernel 6.18.33.2-2 · Ubuntu (stopped) + docker-desktop (running), ambos WSL 2 |
| driver NVIDIA | 610.88 (WDDM) · CUDA 13.3 |
| torch dentro do docling | 2.13.0+cu130 — `cuda_available: True` |
| docling-serve | **1.30.0** (imagem `ghcr.io/docling-project/docling-serve:latest`, build de ~10/08) |
| ollama/ollama | latest (`77f1a2a54460`, 8,35 GB) |
| open-webui | `:main` (`6a773e5c3a24`, 7,16 GB, healthy) |
| nvidia/cuda | 12.8.1-base-ubuntu24.04 (imagem de teste) |

---

## 5. Arquitetura implantada

```
Windows 11 (IA-SERVER)
  └─ WSL2 (2.7.11) ── Docker Desktop ── rede bridge "juridico" / "juridico-ai-network"
       ├─ ollama        :11434  → qwen3:30b / gpt-oss:20b / deepseek-r1:32b / nomic-embed-text
       ├─ open-webui     :3000  → interface, Knowledge/RAG (engine=docling, hybrid search ON)
       ├─ docling        :5001 (bound em 127.0.0.1 — não exposto) → extração/OCR/tabelas/layout
       ├─ qdrant         :6333  → vetores          (na v1.0 real ainda NÃO havia container!)
       ├─ postgres       :5432  → metadados/auditoria (idem: não implantado em 17/08)
       ├─ redis          :6379  → filas             (idem)
       └─ juridico-api   :8088  → FastAPI (v1.2)    (planejado)
```

- **Rede interna:** DNS por nome de serviço (`http://ollama:11434`, `http://docling:5001`).
  Nunca usar `localhost` por dentro do container.
- **Volumes nomeados:** `juridico-ollama-data`, `juridico-open-webui-data`,
  (v1.2 adiciona `qdrant-data`, `postgres-data`, `redis-data`).
- **Regra crítica que sobreviveu a todos os guias:** `docker compose down -v` é proibido sem backup;
  [`docker system prune` / `volume prune` proibidos durante auditoria].

---

## 6. Configurações efetivas (do diagnóstico v2, verificado em runtime)

### Open WebUI (env confirmado no container)
```
CONTENT_EXTRACTION_ENGINE=docling
DOCLING_SERVER_URL=http://docling:5001
RAG_EMBEDDING_ENGINE=ollama
RAG_EMBEDDING_MODEL=nomic-embed-text
ENABLE_RAG_HYBRID_SEARCH=true
RAG_FILE_LOADER_TIMEOUT=600   DOCLING_TIMEOUT=600
DOCLING_SERVE_MAX_SYNC_WAIT=600
DOCLING_SERVE_ARTIFACTS_PATH=/opt/app-root/src/.cache/docling/models
```

### `.env` (exemplo v1.2 — sem segredos reais)
```
TZ=America/Sao_Paulo
OLLAMA_PORT=11434   OPENWEBUI_PORT=3000   QDRANT_PORT=6333
API_PORT=8088       POSTGRES_PORT=5432    REDIS_PORT=6379
POSTGRES_DB=juridico  POSTGRES_USER=juridico
POSTGRES_PASSWORD=ALTERE-ANTES-DE-PRODUCAO   ← placeholder; trocar em produção
OLLAMA_HOST=0.0.0.0:11434   OLLAMA_KEEP_ALIVE=30m
RAG_EMBEDDING_ENGINE=ollama  RAG_EMBEDDING_MODEL=nomic-embed-text
ENABLE_RAG_HYBRID_SEARCH=true
```

### docling (container em produção real de 17/08)
- GPU: `deploy.devices` nvidia + `CUDA available=True` (torch 2.13.0+cu130, RTX 5090).
-Porta publicada **apenas em 127.0.0.1:5001** (boa prática mantida).
- Versão confirmada via metadados de pacote: **docling-serve 1.30.0**
  (o CLI `docling-serve version` não existe — entregou "No such command"; aprendizado capturado).

---

## 7. Modelos em uso (17/08/2026)

| Modelo | Tamanho | Papel no fluxo | Notas |
|---|---|---|---|
| **qwen3:30b** | 18 GB | Motor principal (análise + redação) | MoE, contexto até 256K; melhor PT-BR jurídico entre os três |
| **deepseek-r1:32b** | 19 GB | Segunda opinião / auditoria crítica | R1 reasoning; 128K |
| **gpt-oss:20b** | 13 GB | Raciocínio agentic / function-calling | 128K |
| **nomic-embed-text** | 274 MB | Embeddings (RAG) | não é chat |

Regra de VRAM (plano DeepSeek): Q4_K_M → Qwen3:30b ≈ 19 GB, DeepSeek-R1:32b ≈ 19 GB, GPT-OSS:20b ≈ 14 GB,
+5–8 GB por 32k de contexto. **Nunca 2 modelos grandes simultâneos na VRAM de 32 GB** (a não ser 20b + 30b devagar).
Contexto inicial sugerido: `num_ctx=8192` para não estourar na 1ª execução.

---

## 8. Conteúdo criado no pré-projeto (por ferramenta)

### 8.1 chatgpt.com (artefato principal)
- **Pacote-Juridico-Local v1.0** — composto piloto:
  - `docker-compose.yml` (só ollama + open-webui), `.env`,
  - **GUIA-JURIDICO-LOCAL.md** (11 KB, 46 seções) — da formatação da máquina à criação dos agentes;
  - **prompts jurídicos v1.0** (00-principios, 01-analista, 02-estrategista, 03-redator, 04-auditor, 05-pesquisa, 06-peticao);
  - **scripts ps1: install, pull-models, start, stop, status, logs, update, backup, test-gpu, test-models** (unit-test scripts verificados no §9);
  - guias em 3 versões (md + docx embutidos).
- **Pacote-Juridico-Local v1.2** — modularização:
  - app: `api/main.py` (FastAPI /health, /pipeline/status, /cases); `ingestion/ingest.py`
    (hash SHA-256, mime, classificação por nome → peticao/contestacao/replica/sentenca/acordao/despacho/decisao/recurso/contrato/procuracao/jurisprudencia/outro);
  - extracting `schema.json` (process_number, court, parties, lawyers, dates, amounts, legal_references, requests, events, source_pages, confidence);
  - `state-machine.json` com 14 estados e `human_gate_before: RELEASED`;
  - docs in-code: ARQUITETURA / MODELO-DADOS / OPERACAO / SEGURANÇA / CHANGELOG;
  - **prompts v1.2** (00-sistema + 8 prompts de auditoria, jurisprudência, docx);
  - scripts v1.2 (`install-v1.2`, `run-ingestion`, `run-pipeline`, `test-api`, `backup-v1.2`, `generate-docx`, etc.);
  - `tests/TESTE-PILOTO.md` — teste de cross-leak entre processos A/B.

### 8.2 Diagnósticos (artefatos de auditoria, reutilizáveis como checklist)
- **chatgpt.com/DIAGNOSTICO-JURIDICO-v1(0.1)** — 24 arquivos, snapshot completo (Windows, CPU/RAM, NVIDIA, WSL, Docker, containers, imagens, volumes, redes, portas, Ollama/Open WebUI/Docling/Qdrant/Postgres/Redis, sanitização/host-mounts, disco, ferramentas, serviços). Resumo sanitizado capturou **3 erros de template PowerShell** (§10).
- **qwen.ai/DIAGNOSTICO-JURIDICO-v2** — auditoria dirigida com matriz (pergunta → arquivo):
  A) Docling usa RTX 5090? **PASS**  B) versão docling-serve? **1.30.0** (via metadado)
  C) compose completo? (masked + resolved em anexo)  D) armazenamento RAG? **PASS**  E) modelos efetivos? (fotos instantâneas).
- **deepseek.com** — 3 scripts ps1 de auditoria (5c3587 com nomes `juridico-docling` etc.,
  8b61ef variante sem acentos, auditoria2 alias) + estudo Docling vs. Kreuzberg (PDF 617 KB).

### 8.3 Documentação e governança (Perplexity + Claude)
- Perplexity critica o guia v1.0 e **propõe 16 seções novas (32–47)**: separação dev/prod,
  (RBAC/perfis/logs), citações obrigatórias com formato padronizado, conferência estruturada,
  jurisprudência (metadados + validação), versionamento, matriz de permissões por processo,
  retenção/exclusão, anonimização de dados de teste, plano de DR, registro de versões de modelos/prompts,
  checklist de protocolo / proibição de protocolo automático, LGPD e sigilo, fases 1–5, contatos.
- Resultado: **GUIA v1.1** (2 docx + 1 md) e **adendo v1.1** (zip contendo md/docx) — é a base da v1.2.

### 8.4 Visuais
- `gemini.google.com/esquema.png` — diagrama de rede (23,5 KB).
- `qwen.ai/Qwen_text_20260816_38uqq5tts.txt` — diagrama ASCII de fluxo/rotas:
  `open-webui → ollama:11434 ; docling:5001 (extração/OCR/tabelas/layout)`, acesso `http://localhost:3000`, "só você, no escritório / VPN".

### 8.5 Guia-princípio fora do escopo técnico
- `Como escolher a ferramenta de IA.md` / `HOW_TO_CHOOSE.md` (PT/EN) — metodologia de seleção de IAs
  (comece do problema → caso de uso → fatores → teste → longo prazo). Não é do ambiente técnico,
  mas documenta o **critério de escolha das IAs que geraram o pré-projeto**.

---

## 9. Catálogo de scripts (o DevOps vai usar isso)

| Script | Pasta | Função | Cuidado |
|---|---|---|---|
| `install.ps1` | v1.0 | docker version → GPU self-test (container nvidia/cuda:12.8.1) → compose pull/up → pull de 4 modelos → status + list + nvidia-smi | Roda `docker compose pull` (atualiza todas as imagens) |
| `pull-models.ps1` | v1.0/1.2 | baixa os 4 modelos + list | ~50 GB de download em disco WSL |
| `start.ps1` / `stop.ps1` | ambas | compose up -d / down | down **não** usa `-v`; manter assim |
| `status.ps1` | v1.2 | containers + ps do compose | |
| `logs.ps1` | ambas | compose logs de um serviço | |
| `update.ps1` | v1.0 | compose pull + up -d | sempre **backup antes** |
| `backup.ps1` | v1.0 | tar.gz dos volumes open-webui e ollama para `./backups/` com timestamp | usa container alpine; precisa do volume já existir |
| `test-gpu.ps1` | v1.0/1.2 | self-test GPU via container cuda + `docker exec ollama nvidia-smi` | primeiro teste a rodar após formatação |
| `test-models.ps1` | v1.0 | um "Responda apenas OK." em cada modelo → valida inferência | 3 modelos grandes carregados sequencialmente (lento) |
| `run-ingestion.ps1` | v1.2 | chama ingest.py no container data | |
| `run-pipeline.ps1` | v1.2 | placeholder do pipeline completo (parametros ClientId/CaseId/PieceType) | **não implementado de fato**; só imprime as etapas |
| `test-api.ps1` | v1.2 | GET /health e /cases | |
| `backup-v1.2.ps1` / `generate-docx.ps1` / `install-v1.2.ps1` | v1.2 | variantes v1.2 | |

---

## 10. Erros encontrados e lições aprendidas (seção DevOps)

1. **Template parsing do Docker no PowerShell-5.1** (`DIAGNOSTICO v1.0.1`, arquivo 19):
   `docker inspect --format '{{range .Mounts}} {{...}}'` → `unexpected "\\"`.
   Causa: PowerShell converte `"` interno em `\` no argumento.
   Fix recomendado: buscar via `docker inspect` no **container** usando Python/jq
   dentro do shell, ou escrever o format num arquivo (single-quoted raw).
2. **`docling-serve version` não existe** → aprender a ler versão por `importlib.metadata` / metadados do pacote
   (`docling-serve: 1.30.0`); a opção do CLI mudou entre releases.
3. **Encoding:** arquivos do DeepSeek e do Perplexity saíram com mojibake
   (nomes acentuados viraram `??` no disco) e o arquivo `04-WSL.txt` ficou
   em UTF-16 com espaçamento entre caracteres → leitura quebra em ferramentas bash
   puras. Aprendizado: **definir `chcp 65001` / `Out-File -Encoding utf8`**
   e **testar cada IA aderente ao padrão UTF-8 sem BOM**.
4. **Nomes de arquivos com HTML-escape** (`Meu papel aqui serǭ…`, `\!` do modo adorno):
   o DeepSeek entregou markdown com escapes (`\*`, `\-`, `\!`) — normalizar quando salvar no repo.
5. **VRAM:** dois 30b não cabem juntos; um por vez; `num_ctx` começa em 8192.
6. **Confiar em saída de LLM sem conferir:** os exemplares do repositório incluem
   **duas versões do mesmo guia (DOCX) com tamanhos fortemente divergentes** (48 KB vs 387 KB) —
   conferir tamanho/conteúdo antes de tratar como canônico.
7. **Estados fantasma:** no snapshot real de 17/08 **não existia** Qdrant/Postgres/Redis
   (o compose v1.0 não os tinha); diagnosticar o que existe, não o que "deveria existir".
8. **Perimeter sanitization:** os dois diagnósticos transformaram senhas em `[***]`
   e recusaram conteúdos de clientes; manter essa rotina ao reusar os scripts.
9. **Nunca rodar em produção real:** `docker system prune`, `docker volume prune`,
   `docker compose down -v`.

---

## 11. Inventário completo (Y:\Machine Learning\medusa)

```
medusa/
├── Como escolher a ferramenta de IA.md   (3.8 KB)   guia genérico PT
├── HOW_TO_CHOOSE.md                      (3.2 KB)   mesmo guia EN
├── chatgpt.com/
│   ├── DIAGNOSTICO-JURIDICO-v1.0.1.ps1              (10.5 KB)
│   ├── DIAGNOSTICO-JURIDICO-v1.0.1.ps1.md           (19 KB)   explicação do script
│   ├── DIAGNOSTICO-JURIDICO-v1.0.1-PACOTE.zip       (3.6 KB)
│   ├── DIAGNOSTICO-JURIDICO-v1.0.1.zip              (22.7 KB) — snapshot dos logs
│   ├── DIAGNOSTICO-JURIDICO-v1.ps1                  (10.2 KB)
│   ├── DIAGNOSTICO-JURIDICO-v1/                     24 txt (01..23 + RELATORIO-GERAL)
│   ├── Pacote-Juridico-Local-v1.2.zip               (54.7 KB)
│   ├── Pacote-Juridico-Local-v1.0/                  compose, .env, GUIAS md/docx (3), MANIFEST, README,
│   │                                                prompts/(7), scripts/(10), templates/
│   └── Pacote-Juridico-Local-v1.2/                  compose, .env, MANIFEST, README, docx,
│                                                    app/(api, classifier, extractor, ingestion, ocr, pipeline, security),
│                                                    docs/(5), knowledge/(2), prompts/(9), scripts/(12), templates/, tests/
│   [zip v1.0 não incluído no espelho]
├── claude.ai/GUIA-JURIDICO-LOCAL-v1.1-ADENDO.zip    (24.6 KB) — contém adendo.md + adendo.docx
├── deepseek.com/
│   ├── auditoria2.ps1.ps1                           (2.3 KB)
│   ├── deepseek_powershell_20260817_5c3587.ps1      (4.0 KB)  — nomes `juridico-*`
│   ├── deepseek_powershell_20260817_8b61ef_v1.0.1.ps1 (2.4 KB) — sem acentos
│   ├── Docling vs. Kreuzberg.pdf                    (617 KB)
│   └── Plano de Implementação Tático_medusa_deepseek.md (36 KB) [nome com mojibake]
├── gemini.google.com/esquema.png                    (23.5 KB)
├── perplexity.ai/
│   ├── GUIA-JURIDICO-LOCAL-v1.1_a.docx              (387 KB)  — guia completo v1.1
│   ├── GUIA-JURIDICO-LOCAL-v1.1_b.docx              (48 KB)   — versão enxuta
│   ├── GUIA-JURIDICO-LOCAL.md                       (7.4 KB)  — análise da Perplexity
│   └── pode implementar "Alterações importantes…".md (1.8 KB) [nome com mojibake]
└── qwen.ai/
    ├── DIAGNOSTICO-JURIDICO-v2_2026-08-17_163514/   19 txt (00-RESUMO, 01..18, 99-LEIA-ME)
    ├── DIAGNOSTICO-JURIDICO-v2_2026-08-17_163514.zip (17.3 KB)
    ├── diagnostico-v2.ps1                           (17.2 KB)
    └── Qwen_text_20260816_38uqq5tts.txt             (0.8 KB)  — diagrama de rede
```
*(~88 itens. Verificação de integridade: todos os arquivos listados puderam ser lidos —
nenhum "access denied"; 3 nomes com mojibake ainda legíveis via wildcard; 04-WSL.txt é UTF-16.)*

---

## 12. Glossário para novos DevOps

- **JURIDICO-AI / Pacote Jurídico Local** — nome interno do pré-projeto (~ago/2026), ancestral direto do projeto-medusa.
- **IA-SERVER** — host físico onde tudo roda (ASUS, RTX 5090).
- **`down -v`** — apaga todos os volumes de dados (modelos, chats, uploads): **nunca** executar sem etapa de backup anterior (ver §5/§10).
- **presets** — modelos "agente" do Open WebUI; aqui: Analista(T=0.1), Estrategista(0.4), Redator(0.7), Auditor(0.2) —
  todos apontando para `qwen3:30b` com system prompts distintos (plano DeepSeek).
- **hybrid search** — busca vetorial + textual, ligada no Open WebUI.
- **gate humano** — último estado antes de RELEASED (protocolo manual, nunca automático).

---

## 13. Estado de maturidade na entrada do projeto-medusa

| Aspecto | Estado em 17/08 | Dívida reconhecida                     |
|---|---|---|
| Infra base | ✅ funcional (ollama/webui/docling com GPU) | qdrant/postgres/redis não implantados |
| Pipeline jurídico | 🟡 módulos desenhados (v1.2), `run-pipeline` stub | OCR↔indexação↔análise não integrados end-to-end |
| Governaça | 🟡 advinda da v1.1 (16 seções) | RBAC/logs reais não implementados |
| Testes | 🟡 TESTE-PILOTO.md | não executado |
| Segurança | 🟡 boas práticas no compose (ports internos, VPN) | auth, HTTPS, criptografia — pendente |
| Backup | ✅ backup.ps1 funcional | política de retenção/DR pendente |
| Integração contínua | ❌ ausente | força do projeto-medusa a construir |

**Caminho recomendado ao retomar:** (1) subir o stack v1.2 completo (com qdrant/postgres/redis),
(2) rodar `test-gpu` + `test-api`, (3) executar TESTE-PILOTO com 5–10 docs anonimizados,
(4) implementar as 16 seções de governança da v1.1 antes de dados reais,
(5) só depois evoluir para o estado "projeto-medusa v1".

---

*Documento gerado em 25/10/2026 a partir de leitura somente leitura de 88 itens de
`Y:\Machine Learning\medusa\`. Fonte primária dos fatos técnicos: os diagnósticos
v1 e v2 (17/08/2026), que capturaram o estado real da máquina no dia.*
