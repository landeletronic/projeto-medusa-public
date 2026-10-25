# HISTÓRICO PRÉ-PROJETO — MEDUSA (Fase 1: ago/2026 · Fase 2: set–out/2026)

> **Documento de referência histórica.** Consolida todo o material dos dois acervos
> que precederam o atual **projeto-medusa**:
>
> | Parte | Fonte | Período | Ambiente |
> |---|---|---|---|
> | **I** | `Y:\Machine Learning\medusa\` (espelho dos trabalhos em `C:\AI\JURIDICO-AI`, máquina **IA-SERVER**) | 13/08 → 17/08/2026 | Windows 11 + WSL2 + Docker Desktop |
> | **II** | `C:\Intel\medusa\projeto-medusa_e_davy-jones_17092026\` | 12/09 → 25/10/2026 | Proxmox VE + VM Ubuntu ("Caribbean Pirates GPT"/Davy-Jones/Medusa) |
>
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
- RAM XMP: módulos 6000 MT/s rodando em **4800** — confirmado tanto no Windows (17/08, `02-CPU-RAM.txt`)
  quanto no Proxmox (16/09 — `Configured Memory Speed: 4800 MT/s`). Ajuste executado posteriormente pelo
  operador — ver **§3.1 BIOS/UEFI**.


### 3.1 BIOS/UEFI do servidor (documentada — placa ASUS TUF GAMING B650M-E WIFI)

Ajuste de BIOS feito pelo operador nesta fase, com checklist de estado desejado e
diagnósticos antes/depois. Fontes: `docs-old/Checklist de BIOSUEFI (ASUS TUF GAMING B650M-E WIFI).xlsx`,
`docs-old/BIOS.pdf` (1 página com 9 screenshots de telas de BIOS), `docs-old/proxmox_diagnostico_pve-asus_20260916_183836_editado.txt`
e `...20260918_195922.txt` · consultado em 25/10/2026.

#### Checklist oficial do acervo (fonte: XLSX)

| Item (BIOS ASUS) | Estado desejado | Situação no diagnóstico pré-ajuste |
|---|---|---|
| **SVM Mode** | Enabled | ✅ OK — `kvm_amd` ativo |
| **IOMMU** | Enabled | ✅ OK — AMD-Vi no dmesg |
| **Secure Boot** | Disabled | ✅ OK — `secureboot:0` |
| **Above 4G Decoding** | Enabled | ⚠️ Verificar — obrigatório para mapear 32 GB de VRAM no passthrough |
| **Re-Size BAR Support** | Enabled/Auto | ⚠️ Verificar — impacta desempenho do driver NVIDIA no guest |
| **Initiate Graphic Adapter / Primary Display** | **IGFX (iGPU AMD)** | ⚠️ Verificar — crítico: a 5090 não pode ser a GPU de console |
| **PCIEX16 Bandwidth (slot da 5090)** | **Gen5** | ⚠️ Negociando Gen4 — dmesg mostra 16 GT/s em link capaz de 32 GT/s |
| **Fast Boot** | Disabled | ✅ Recomendado (reset de GPU mais limpo) |
| **EXPO/XMP (memória)** | Opcional | ⚠️ Rodando 4800 MT/s em pentes de 6000 (Corsair CMK32GX5M2B6000C38) — EXPO desativado |

#### Configuração executada pelo operador (confirmada em conversa, 25/10/2026)

1. **XMP/EXPO habilitado** — elevar a DDR5-6000 dos pentes Corsair (antes travados em 4800);
2. **PCIEX16 habilitado em Gen5 (PCIe 5x)** — forçar o slot da RTX 5090 a negociar Gen5 em vez de Gen4.

> ⚠️ **Nota de validação:** o acervo NÃO contém um log pós-ajuste confirmando essas duas
> mudanças em execução (o último diagnóstico Proxmox é de 18/09, ainda em Gen4/4800).
> **Para um DevOps futuro, revalidar na próxima janela:**
>
> ```bash
> # Velocidade de RAM efetiva (esperado: 6000 MT/s com EXPO ativo)
> dmidecode -t 17 | grep -i "Configured Memory Speed"
> # Link PCIe da RTX 5090 (esperado: 32 GT/s = Gen5 x16)
> lspci -vv -s $(lspci | grep -i nvidia | cut -d' ' -f1) | grep -i lnksta
> # via nvidia-smi, alternativa no guest:
> nvidia-smi -q | grep -iA3 "PCIe Generation"
> ```

Lições do item (representadas também nos diagnósticos):
- Diminuir uma geração PCIe (Gen5→Gen4) **não impede** o passthrough de funcionar;
  validações de 13–18/09 já assumiam Gen4 em execução — mas o checklist tratava
  "Gen5" como meta de desempenho, não como pré-requisito.
- O NVMe Kingston NV3 (SM2268XT2, DRAM-less) reportou limitação estrutural de
  **PCIe x2 @ 16 GT/s** ("31.5 Gb/s available bandwidth") — *afetando apenas o
  throughput de armazenamento, não a GPU*.
- A máquina tem **iGPU AMD** cuja tarefa (no BIOS) é ser a GPU de console no host,
  deixando a 5090 livre para o passthrough da VM "Medusa" (VMID 1001).

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

# PARTE II — Pré-projeto Fase 2: "projeto-medusa + davy-jones" (12/09 → 25/10/2026)

## 14. Fonte e dimensionalidade do acervo

Diretório-fonte: `C:\Intel\medusa\projeto-medusa_e_davy-jones_17092026\`
**1.257 arquivos · 88 diretórios · ~2,0 GB** — leitura 100% concluída em 25/10/2026 (sem arquivos ilegíveis;
`.tar.gz`/`.deb`/`.so`/`.sqlite3` são binaries íntegros).

Composição por tipo:

| Tipo | Qtde | Conteúdo |
|---|---:|---|
| `.log` | 456 | logs de execução, 1 para cada script/validação rodada |
| `.sh` | 210 | scripts de instalação/auditoria (famílias U0/C/H/M4/M5/MEDUSA) |
| `.py` | 152 | pipelines RAG, gates de evidência, diagnósticos |
| `.json` | 123 | resultados/validações com data/hora |
| `.md` | 85 | documentação por etapa |
| `.txt` | 67 | relatórios e cópias textuais |
| `.tar.gz` + `.sha256` | 43+33 | backups diários com hash |
| PDFs/DOCX/PNG | 16/6/14 | relatórios, manuais (Manual_Usuario_Medusa_Evidencia_Juridica.pdf, ia-server-diagnostic.pdf, kit visual) |

## 15. Cronologia documentada da Fase 2

| Data (2026) | Evento | Evidência no acervo |
|---|---|---|
| 12–13/09 | Diagnóstico do hardware (mesmo equipamento da Fase 1, migrado) | `docs-old/ia-server-diagnostic-20260913-210159.log` |
| 16–18/09 | Diagnósticos do Proxmox `pve-asus` (IOMMU/VFIO ok; árvore PCI) + **checklist BIOS** | `docs-old/proxmox_diagnostico_pve-asus_20260916/18*.txt`, **XLSX BIOS** |
| 17/09 | Arquitetura-alvo: **00-arquitetura-geral.md** (PROPOSTA — 24 seções); criação da pasta datada `17092026` | `md/00-arquitetura-geral.md` |
| 17/09 | Kit visual do projeto (imagens "medusa e davy-jones") | `png/ChatGPT Image 19 de set…` |
| 19/09 | Status oficial do projeto; **112 logs no dia** (dia mais intenso) | `md/MEDUSA_Status_Projeto_2026-09-19_multiwan-gmail.md` |
| 20/09 | Cadeia **Calypso** (gateway do Codex): C1 → C12 com 12 revisões (sandbox, userns/apparmor/seccomp, systemd) | `script/C*.sh`, `log/C*.log` |
| 21/09 | Auditorias Mem0/Qdrant 2560 (coleções hermes_eng_memory_v2, mem0migrations, medusa_docs_v1) | `log/AUDIT-MEM0-QDRANT-2560-20260921*.log` |
| 22/09 | **M4.2/M4.3** — implantação do Docling + documentação por documento | `txt/M4.2-I-docling-implementation*`, `script/M4.2-I-implantar-docling.sh` |
| 23–27/09 | **M4.4 → M4.21** — pipeline RAG limpo: embeddings Qdrant, retriever + stress, gates de evidência, verificação ambígua/adversarial, layout-aware, tabelas | `script/M4.*.py` |
| 25/09 | **Estado oficial versionado** `2026.09.25-r1` (checkpoint M4/M5 + regras permanentes) | `md/01-estado-oficial-projeto-caribbean-pirates.md` |
| 28/09 | Transferência M5.14 → M5.24-D4; relatório de progresso; diagnóstico de **não-determinismo de embeddings** (D4, 6 revisões) | `md/Caribbean_Pirates_GPT_Medusa_Transferencia…`, `docs/M5.24-D4*` |
| 29/09 | D7/D8/D9 (origem do cold/warm) + **E1/E2 BGE-M3** (determinismo e qualidade vs modelo alternativo) | `docs/M5.24-D7..E2*` |
| 30/09 | **MEDUSA-AEL B1–B6** — laboratório de engenharia supervisionada com Codex (auth, sandbox, multiagente adversarial) | `script/MEDUSA-AEL-B*.py`, `docs/MEDUSA-AEL-B*` |
| 01/10 | **Produção**: `MEDUSA-PRODUCTION-R1` ativa Medusa Core/Davy-Jones; relatório de status completo; backup com árvore extraída (79 itens) | `md/RELATORIO-MEDUSA-DAVY-JONES-STATUS-2026-10-01.md`, `backups/operational-20261001T121501446664Z/` |
| 02/10 → 25/10 | **Snapshots operacionais diários automáticos** (timer systemd, ~06:35 UTC; 34 snapshots tar.gz + sha256 + manifest) | `backups/Medusa/operational-2026100x…` |
| 19/10 → 25/10 | Backups diários do **Hermes-lab/Honcho** (8 tar.gz, últimos ~72 MB) | `backups/hermes-lab/hermes-*.tar.gz` |
| 25/10 | Documentação da fase (este arquivo) | `medusa-opencode/docs/pre-projeto` |

## 16. Infraestrutura da Fase 2 (Proxmox)

### 16.1 Host `pve-asus`
- **Proxmox VE 9.x** (kernel PVE `7.0.2-6` linux) · mobo ASUS TUF GAMING B650M-E WIFI
- CPU **Ryzen 9 9950X3D** · 32 GB DDR5 · RTX 5090 32 GB **passada integralmente à VM** (IOMMU+VFIO validados)
- Kingston NV3 NVMe ~1 TB (limitação de link PCIe x2 observada — *constatação do acervo*)
- BIOS ajustado pelo operador conforme §3.1 (XMP/EXPO + PCIe Gen5)

### 16.2 VM "Medusa" (VMID 1001)
- Ubuntu Server **26.04.1 LTS** · **30 vCPU** · **24 GB RAM** · disco **750 GB**
- **Tailscale** operacional · Docker operacional · `tlandskron` fora do grupo `docker` (regra permanente)

### 16.3 Serviços centrais da VM
PostgreSQL **+ pgvector** · Redis · Ollama · **Qdrant** · Docling Serve · Mem0 OSS (Hermes Engineering)

### 16.4 Embedding contratado (decisão de engenharia)
- Modelo: **qwen3-embedding:4b** · dimensão fixa **2560**
- Qdrant escolhido para índice 2560; **não-determinismo de embeddings** detectado ⇒ cadeia D4 (6 diagnósticos)
  + comparativo bge-m3 (E1/E2) — *corpus sempre congelado por SHA antes/depois de qualquer mudança*

## 17. Aplicação da Fase 2 (código e gates)

### 17.1 Medusa Core — `http://127.0.0.1:8765`
- Python 3.14 **stdlib-only** (sem dependências extras) — `medusa/core/medusa_core/{__main__,workspace}.py`
- Recuperação de **evidência** com proveniência (documento + páginas + chunk) e estado explícito:
  `GROUNDED / PARTIAL_REVIEW / ABSTAIN / REVIEW_REQUIRED`
- *"Recuperação vazia nunca estabelece conclusão jurídica"* — garantia de interface (não-generativa)
- Corpus canônico: **206 pontos** Qdrant (`medusa_rag_chunks_v1`), coleção `medusa_workspace_*` por documento;
  `config/core.json` aponta chunks M5.11 `c-flow-balanced` (SHA `4309a4e7…`)
- UI embutida CSP-restrita (`X-Frame-Options`, sem logging de payload) · payload `POST /query|/draft|/workspace/query`
- Isolamento de escopo: `canonical` (corpus validado) vs `workspace` (ingestão incremental)

### 17.2 Davy-Jones — `http://127.0.0.1:8766`
- Orquestrador de jobs com **fila persistente** (`data/jobs.sqlite3`, SQLite WAL, ≤3 tentativas, idempotency-key)
- Tipos de job: `query / draft / workspace_query / workspace_draft / documents / readiness / ingest`
- Ingestão segura somente de `/home/tlandskron/medusa/documents/incoming` (≤20 MiB, sem symlink)
- Administração: token local em `config/admin.json` (mode 0600); bind **apenas em loopback** → acesso remoto só por SSH tunnel
- Serviço `systemd --user` (`davy-jones.service`, `medusa-core.service`) + timers `medusa-davy-health` e `medusa-davy-backup`

### 17.3 Hermes / Honcho / Calypso — cadeia de engenharia (separada da aplicação funcional)
- **Calypso**: gateway do Codex na C1 → C12 (r0–R2A) — preflights read-only, *freezes*, sandbox
  (bubblewrap probe), userns/apparmor/seccomp forensics, socket activation nativa, unit verify (systemd)
- **Hermes nativo no Ubuntu (H1–H30)**: política ABC *operation-by-operation* (audit → install →
  e2e → repair → revalidate), gates de approval integrados, 2560-dim Mem0, terminal policy simulation (H28/H29)
- **Honcho v3.2.0 (U0.16)**: laboratório isolado com privilégio mínimo PostgreSQL, migrations Scram
  controladas, runtime API com pipeline multipeer/deriver com Injeção de Falha Controlada (IFC), embedding real
  qwen3 (U0.16.3.7.10.6.5-R1..R9 - integração persistente quebrada/rollback/compose-service-key → R3) —
  *caso de estudo de rollback organizado*

### 17.4 Regra permanente de autorização (regra de ouro da fase)
- **Nenhum script sem autorização explícita e específica**; cada etapa versionada (`-R<n>`, `-REENTREGA`, `CLOSE`)
- **Toda validação é tripla:** JSON com data/hora + cópia `.log` idêntica em `/home/tlandskron/log` + registro `.txt` estável
- *"Plano → documentar → revisar → autorizar → executar → validar → documentar" — nenhuma fase é
  considerada concluída só porque um comando terminou sem erro*

## 18. Estado em 01/10/2026 (relatório oficial)
- ✅ Operacional: Medusa Core, Davy-Jones (Agent/Tool-Orchestrator), Mem0, Qdrant, Ollama (qwen3:8b), RAG API/Worker, Docling, SearXNG, **PostgreSQL/pgvector + Redis**, RTX 5090/CUDA, backup remoto SMB/Tailscale
- ❌ Pendente: Open WebUI (não instalada), Nginx/HTTPS, Prometheus/Grafana/Loki/Alertmanager/Uptime-Kuma, Planner avançado, **backup externo (nuvem/home-office)**, monitoramento externo
- 🔒 Preservado: M5.23 SHA idêntico em 3c3902f3…; corpus 206 pontos intacto
- Testes registrados: 18 regressões recuperação + 12 extensão + 4 fila DJ + 8 Chromium + 2 PDFs reais consultados com página/chunk + outage/kill/recovery/backup-restore

## 19. Volume de trabalho documentado (da Fase 2)

**Fase de construção intensiva** (densidade comprovada pela data/hora dos logs):

| Janela | Dias com evidência | Logs no período |
|---|---|---:|
| 13/09–18/09 (Proxmox+BIOS+arquitetura) | 4 | ~5 relatórios grandes |
| 19/09–21/09 (setup laboratórios) | 3 | **228** |
| 22/09–27/09 (M4.x pipeline RAG) | 6 | 89 |
| 28/09–29/09 (M5.x + determinismo) | 2 | 43 |
| 30/09–01/10 (AEL + produção R1) | 2 | ~40 |

Total: **≈400 logs/validações auditáveis em 13 dias** de execução (12/09 → 01/10) + **24 dias de operação
automática de backup** (02/10 → 25/10, timer diário sem intervenção) + **8 backups Hermes** (19–25/10).
- Estimativa conservadora de esforço humano: **Fase 1 ≈ 30–40 h · Fase 2 construção ≈ 60–90 h ·
  Fase 2 operação ≈ 8–12 h** de supervisão ao longo de 6 semanas. **TOTAL PRÉ-PROJETO ≈ 100–140 h**
  entre agosto e outubro/2026.

## 20. Lições da Fase 2 (para DevOps futuro)

1. **Proxmox + passthrough**: IOMMU/VFIO validados **antes** de qualquer serviço; sem o
   *Above 4G Decoding* + *Re-Size BAR* a 5090 (32 GB de VRAM) pode não mapear toda a memória no guest.
2. **Embedding não-determinista é problema real**: gerou 11 diagnósticos dedicados (série D4) +
   comparativo de modelo — proteger o corpus por **SHA antes/depois** evitou regressão silenciosa.
3. **Rollback elegante**: caso Honcho compose-service-key (U0.16.3.7.10.6.5-R9) — serviço quebrado →
   rollback → forense read-only → correção nova revisionada (R9-R1..R3) sem perder o histórico.
4. **Artefato prevalece sobre conversa**: o "estado oficial" (25/09) explicita
   *"em conflito entre uma resposta conversacional e os artefatos validados, os artefatos prevalecem"* —
   mecanismo anti-deriva potente para agentes de IA.
5. **Fecho de cadeia (CLOSE)**: toda etapa complexa termina com `CLOSE` documentado
   (M5.8/M5.9/M5.10 CLOSE), reconciliando governança e marcando o que existe como encerrado.
6. **Sequência BIOS/GPU**: validar SVM/IOMMU/SecureBoot/Above4G/ReBAR/iGPU-as-console/PCIe-Gen5
   *antes* de subir serviços — o checklist XLSX é o artefato de referência.
7. **A proibição de `down -v` sobreviveu à mudança de era**: mesma regra crítica do §5 aplicada
   ao novo ambiente (Proxmox/Docker/Tailscale).
8. **Dados sensíveis no backup**: o espelho contém documentos reais de processo (PDF jurídico de 10 MB
   e coleções Qdrant com conteúdo de cliente) — **acervo confidencial**; jamais publicá-lo em
   repositório público ou serviço externo.

## 21. Inventário resumido (Fase 2)

```
projeto-medusa_e_davy-jones_17092026/
├── md/        15 relatórios/status (19/09 → 01/10)
├── json/      4 diagnósticos com data/hora (28/09)
├── docx/pdf/  6 + 9 relatórios (inclui Manual_Usuario_Medusa_Evidencia_Juridica_v1.pdf)
├── png/       12 imagens kit visual
├── txt/       13 relatórios de transferência e diagnósticos
├── script/    210 scripts (U0.13/14/15/16, C1–C12, H1–H30, M4.x, M5.x, MEDUSA-AEL/BACKUP/PROD)
├── log/       456 logs (espelho 1:1 das validações; 406 datados)
├── docs/      evidências por etapa em tríade (.json + .log + .txt) + DAVY-* (SearXNG/TOOLS/UI)
├── docs-old/  17: relatórios Proxmox, BIOS.pdf, checklist XLSX, conversas IA
├── incoming/  2 PDFs jurídicos reais do pipeline (processo TRT-4 10 MB)
└── backups/
    ├── Medusa/                 34 snapshots tar.gz (10 do dia 01/10 + 24 diários até 25/10, ~43 MB cada)
    ├── operational-20261001…/  árvore do deploy EXTRAÍDA (79 itens com código-fonte, config e corpus)
    └── hermes-lab/             8 backups Hermes (19–25/10, ~72 MB cada)
```

---

## 22. Glossário complementar (Fase 2)

- **Caribbean Pirates GPT** — nome do umbrella do projeto na Fase 2 (Davy-Jones + Medusa + Hermes Engineering).
- **pve-asus / VMID 1001** — host Proxmox e a VM Ubuntu "Medusa".
- **M4.x / M5.x** — cadeias versionadas do pipeline de documentos/RAG (ex.: M5.11 = materialização
  c-flow-balanced do corpus canônico; M5.14 = indexação Qdrant controlada).
- **CORPUS CANÔNICO** — 206 pontos vetoriais validados, preservados por SHA entre entregas.
- **R-n / D-n / B-n / E-n** — sufixos de revisão/diagnóstico/marco no esquema de versionamento de scripts:
  `Nome-da-etapa-v1.0.0.py` + `-R1` (revisão) + `-D1` (diagnóstico) + `CLOSE` (fecho).
- **ABC (Hermes)** — política de aprovação por operação no Hermes Engineering.
- **Davy-Jones ≠ Hermes Engineering** — orquestrador funcional vs. engenharia/manutenção (isolamento permanente).

---

*Documento gerado em 25/10/2026 a partir de leitura somente leitura.*
- **Fonte Parte I:** 88 itens de `Y:\Machine Learning\medusa\` — diagnósticos v1 e v2 de 17/08/2026.
- **Fonte Parte II:** 1.257 itens de `C:\Intel\medusa\projeto-medusa_e_davy-jones_17092026\` —
  estado oficial 25/09, relatório de status 01/10/2026, diagnósticos Proxmox de 16–18/09/2026 e
  checklist de BIOS/UEFI (`docs-old/`), logs diários e backups até 25/10/2026.*
