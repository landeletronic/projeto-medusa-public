# Stack de Observabilidade — Medusa

**Projeto:** Caribbean Pirates GPT · CARIBBEAN PIRATES GPT
**Host:** `medusa` (Ubuntu 26.04.1 LTS, kernel 7.0.0-38-generic)
**Instalado em:** 2026-10-09
**Escopo desta etapa:** Node Exporter + Prometheus + Grafana

---

## 1. Visão geral

Camada de observabilidade do host medusa, correspondendo ao bloco central do diagrama
de arquitetura do projeto. Por enquanto cobre **métricas de host**; logs centralizados
(Loki) e alertas (Alertmanager) são etapas posteriores.

```
                      ┌─────────────────────────────┐
   ┌──────────────┐   │  medusa (192.168.15.250)    │
   │  Prometheus  │──▶│  127.0.0.1:9090            │
   │  :9090       │   │                              │
   └──────▲───────┘   │  ┌────────────────────────┐  │
          │           │  │ Node Exporter :9100    │  │
   ┌──────┴───────┐   │  │ (pid: host, /host RO)  │  │
   │   Grafana    │──▶│  └───────────┬────────────┘  │
   │  :3000       │   │              │ metrics       │
   └──────────────┘   └──────────────┼───────────────┘
                                   ▼
                          CPU · RAM · disco · rede
                          load · processos · cgroup
```

Ambos os serviços escutam **apenas em `127.0.0.1`**. Não há exposição à LAN até que
o Caddy seja configurado para publicá-los.

---

## 2. Componentes e versões

| Componente | Imagem | Versão | Porta interna | Porta exposta | Limite RAM |
|---|---|---|---|---|---|
| Node Exporter | `prom/node-exporter` | v1.9.1 | 9100 | nenhuma | 256 MB |
| Prometheus | `prom/prometheus` | v3.7.3 | 9090 | `127.0.0.1:9090` | 2 GB |
| Grafana | `grafana/grafana` | 12.3.1 | 3000 | `127.0.0.1:3000` | 1 GB |

Todas as imagens são pinadas por tag exata (sem `latest`), o que torna o deploy
reprodutível.

**Build info do Prometheus:** `3.7.3` / rev `0a41f00` / go1.25.3 / build 2025-10-30

---

## 3. Layout no sistema de arquivos

```
/home/tlandskron/observability/
├── docker-compose.yml                     # definição da stack
├── prometheus/
│   └── prometheus.yml                     # scrape config
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/datasources.yml    # provisiona Prometheus como DS default
│   │   └── dashboards/dashboards.yml      # provider de dashboards em arquivo
│   └── dashboards/
│       └── medusa.json                    # dashboard "Medusa — Overview Host"
└── secrets/
    └── grafana_admin_password             # senha admin (600, uid 472)
```

**Volumes Docker (persistência):**

| Volume | Uso |
|---|---|
| `observability_prometheus_data` | séries de métricas (TSDB) |
| `observability_grafana_data` | banco SQLite, dashboards, plugins |

**Rede:** `observability-net` (bridge, subnet `172.20.0.0/16`)

**Política de restart:** `unless-stopped` nos três containers — sobem sozinhos após
reboot (validado em 2026-10-09).

---

## 4. Acesso

### Endereços

| Serviço | URL local (a partir do próprio host) |
|---|---|
| Grafana | http://127.0.0.1:3000 |
| Prometheus | http://127.0.0.1:9090 |
| Prometheus — alvos | http://127.0.0.1:9090/targets |
| Prometheus — status de build | http://127.0.0.1:9090/api/v1/status/buildinfo |

### Credenciais do Grafana

- usuário: `admin`
- senha: armazenada em `/home/tlandskron/observability/secrets/grafana_admin_password`
  (chmod 600, owner uid 472 — o uid do processo grafana dentro do container)

```bash
# ler a senha
sudo cat /home/tlandskron/observability/secrets/grafana_admin_password
```

> A senha **não** está registrada em texto claro nesta documentação de propósito.
> Durante a instalação ela apareceu no terminal e no histórico da sessão — considere
> rotacioná-la com o procedimento da seção 9.

### Acesso remoto (SSH tunnel)

Até o Caddy ser configurado, o acesso remoto é por túnel:

```powershell
ssh -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090 medusa
```

Depois, no navegador: Grafana em `http://localhost:3000`, Prometheus em
`http://localhost:9090`.

---

## 5. Operação

Todos os comandos rodam **no host medusa**.

```bash
cd /home/tlandskron/observability
D="sudo -n docker"        # atalho

$D compose up -d                          # sobe / aplica mudanças
$D compose ps                             # estado
$D compose logs -f grafana                # logs
$D compose restart prometheus             # reinicia (ex.: após editar scrape config)
$D compose down                           # para (preserva volumes)
$D compose pull && $D compose up -d       # atualiza imagens
```

Para recriar a stack do zero (apaga métricas e estado do Grafana):

```bash
cd /home/tlandskron/observability
sudo docker compose down -v
sudo docker compose up -d
```

---

## 6. Configuração do Prometheus

`prometheus/prometheus.yml` — scrape a cada 15s:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    host: medusa
    project: caribbean-pirates-gpt

scrape_configs:
  - job_name: node          # métricas de host
    static_configs:
      - targets: ['node-exporter:9100']
        labels:
          instance: medusa-node

  - job_name: prometheus    # métricas do próprio Prometheus
    static_configs:
      - targets: ['localhost:9090']
        labels:
          instance: medusa-prometheus
```

**Retenção:** 15 dias por tempo, 8 GB por tamanho (o que vier primeiro).

**Validação da config antes de aplicar:**

```bash
sudo docker run --rm --entrypoint /bin/promtool \
  -v /home/tlandskron/observability/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
  prom/prometheus:v3.7.3 check config /etc/prometheus/prometheus.yml
```

Esperado: `SUCCESS: /etc/prometheus/prometheus.yml is valid prometheus config file syntax`

---

## 7. Dashboard

**Nome:** Medusa — Overview Host
**UID:** `medusa-overview` · **Pasta:** Medusa

11 painéis, todos provisionados a partir de `grafana/dashboards/medusa.json`:

| Painel | Métrica |
|---|---|
| Host Uptime | `time() - node_boot_time_seconds` |
| Núcleos / Cores | contagem de `node_cpu_seconds_total{mode="idle"}` |
| Disco / (uso %) | `node_filesystem_avail_bytes / size_bytes` |
| RAM disponível | `node_memory_MemAvailable_bytes` |
| CPU do host (%) | `100 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))` |
| Memória do host | `MemTotal - MemAvailable` |
| CPU por núcleo (%) | `100 - rate(node_cpu_seconds_total{mode="idle"}[5m])` |
| Load average | `node_load1` / `load5` / `load15` |
| Tráfego de rede do host | `rate(node_network_*_bytes_total[5m])` |
| Uso de disco por filesystem | razão avail/size por mountpoint |
| Processos e contexto de troca | `node_procs_running`, `node_procs_blocked`, `node_context_switches_total` |

O datasource `Prometheus` (`http://prometheus:9090`) é provisionado como default,
então os painéis funcionam sem configuração manual.

Para editar: alterar o JSON no host e recarregar. O provider está com
`updateIntervalSeconds: 30` e `allowUiUpdates: true`, então mudanças feitas pela UI
também persistem — mas serão sobrescritas se o arquivo for editado.

---

## 8. Limitações conhecidas

Esta seção documenta o que **não** funciona e por quê. Foi investigated e não
resolvido na instalação.

### 8.1 Sem métricas por container (cAdvisor incompatível)

O diagrama de arquitetura prevê visualização por container. Isso **não está
disponível**.

O cAdvisor não funciona neste host. O erro:

```
failed to identify the read-write layer ID for container "<id>"
  - open /rootfs/var/lib/docker/image/overlayfs/layerdb/mounts/<id>/mount-id:
    no such file or directory
```

**Causa:** o Docker 29.9 usa storage driver `overlayfs` via
`io.containerd.snapshotter.v1` (confirmado em `docker info`:
`driver-type: io.containerd.snapshotter.v1`). O cAdvisor procura o `layerdb`
legado do driver `overlay2`, que não existe mais nesse modo.

**O que foi tentado:**

| Tentativa | Resultado |
|---|---|
| cAdvisor v0.52.1 padrão | 0 métricas de container |
| + socket `/run/containerd/containerd.sock` montado | ainda 0 métricas |
| + flag `-containerd-namespace=moby` | container sobe `healthy`, ainda 0 métricas |
| Tags mais novas (v0.53.x, v0.54.x) | inexistentes no registro |
| `prometheuscommunity/docker_stats_exporter` | repositório removido do registro |

**Decisão:** remover o cAdvisor em vez de manter um alvo DOWN gerando ruído. Os
painéis por container foram retirados do dashboard para não exibir widgets vazios.

### 8.2 Collectors systemd e cgroups desabilitados

Ambos foram desligados no node-exporter:

- **`systemd`** — falha com `couldn't get dbus connection: dial unix
  /var/run/dbus/system_bus_socket: no such file or directory`. Montar o socket
  dbus do host em container não resolveu.
- **`cgroups`** — não enxerga os cgroups dos containers (0 séries). Seria a
  alternativa para métricas por container, mas também retorna vazio.

### 8.3 Métricas por container: caminho futuro

Quando o storage driver voltar a ser `overlay2`, ou quando o cAdvisor ganhar
suporte ao containerd snapshotter, o caminho é:

1. reativar cAdvisor no compose
2. adicionar o job `cadvisor` ao scrape config
3. reintroduzir os painéis por container

Alternativa a avaliar: exporter dedicado usando a API do Docker
(`/containers/<id>/stats`), que não depende do storage driver. Não foi
implementado por não haver imagem confiável disponível no momento.

---

## 9. Notas de instalação (para reproduzir)

Decisões e armadilhas encontradas durante o deploy.

### Grafana: senha via secret

O Grafana 12 aceita `GF_SECURITY_ADMIN_PASSWORD__FILE`. Dois cuidados:

1. **O secret precisa ser legível pelo uid 472** (processo grafana no container).
   Arquivo com owner `tlandskron` e chmod 600 causa
   `Permission denied` no boot. Correção: `chown 472:472`.
2. **O arquivo não pode ter newline final.** O Grafana lê o arquivo inteiro como
   senha. Um `\n` final faz a senha real ser `XYZW\n`, e o login falha com 401 de
   forma aparentemente inexplicável. Use `printf '%s' "$SENHA"`, nunca
   `echo`.

Gere sem newline e com owner correto:

```bash
SEC=/home/tlandskron/observability/secrets/grafana_admin_password
SENHA=$(openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | head -c 24)
printf '%s' "$SENHA" | sudo tee "$SEC" > /dev/null
sudo chown 472:472 "$SEC" && sudo chmod 600 "$SEC"
```

### Grafana: senha só é aplicada na primeira inicialização

`GF_SECURITY_ADMIN_PASSWORD` só age sobre um banco vazio. Se o volume já existe,
a senha precisa ser resetada manualmente:

```bash
SENHA=$(sudo cat /home/tlandskron/observability/secrets/grafana_admin_password)
sudo docker exec obs-grafana \
  grafana cli --homepath /usr/share/grafana admin reset-admin-password "$SENHA"
```

### node-exporter: `--path.rootfs=/host`

Necessário para que o filesystem collector reporte o disco real do host e não o
container. Requer o bind `- /:/host:ro,rslave` e `pid: host`.

### node-exporter: udev

O `diskstats` collector tenta ler `/run/udev/data` para mapear dispositivos. Sem
o bind, loga `Failed to open directory, disabling udev device properties` —
inofensivo, mas o bind evita o erro.

---

## 10. Checklist de validação

```bash
cd /home/tlandskron/observability
D="sudo -n docker"

# containers no ar
$D compose ps

# targets do Prometheus (esperado: node UP, prometheus UP)
curl -s http://127.0.0.1:9090/api/v1/targets?state=active \
  | python3 -c "import json,sys; [print(t['labels']['job'], t['health']) for t in json.load(sys.stdin)['data']['activeTargets']]"

# métricas chegando (esperado: 240 séries de CPU)
curl -s 'http://127.0.0.1:9090/api/v1/query?query=node_cpu_seconds_total' \
  | python3 -c "import json,sys; print(len(json.load(sys.stdin)['data']['result']))"

# Grafana respondendo
curl -s http://127.0.0.1:3000/api/health

# login no Grafana
SENHA=$(sudo cat secrets/grafana_admin_password)
curl -s -u "admin:$SENHA" http://127.0.0.1:3000/api/user \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['login'])"
```

**Resultado registrado em 2026-10-09:** 2/2 targets UP, 240 séries de CPU,
login `admin` OK, datasource e dashboard provisionados.

---

## 11. Pendências

| Item | Situação | Observação |
|---|---|---|
| Expor via Caddy | pendente | Caddy ainda em `:3000`/`:3443`; Grafana ocupa `:3000`. Planejado Caddy em `:6000` |
| Loki (logs) | pendente | etapa 2, conforme roadmap |
| Alertmanager | pendente | diagrama prevê |
| Uptime Kuma | pendente | diagrama prevê |
| Rotacionar senha do Grafana | recomendado | senha apareceu em terminal durante a instalação |
| Backup dos volumes | pendente | ver `medusa-remote-backup.timer` (destino `openmediavault` estava offline) |

---

## 12. Referências

- Prometheus: https://prometheus.io/docs/introduction/overview/
- Grafana provisioning: https://grafana.com/docs/grafana/latest/administration/provisioning/
- Node Exporter: https://github.com/prometheus/node_exporter
- Docker storage drivers: https://docs.docker.com/engine/storage/drivers/