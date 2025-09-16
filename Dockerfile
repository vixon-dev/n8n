# Latest Version: 1.111.0 (stable-pinned)
FROM n8nio/n8n:1.111.0

# ==== 1) OS deps (Chromium + fontes) ====
USER root
RUN apk update && apk add --no-cache \
    ffmpeg \
    php \
    python3 \
    py3-pip \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    wqy-zenhei \
    font-noto \
    font-noto-cjk \
    git \
    nano \
    bash \
    libc6-compat \
 && ln -sf /usr/bin/chromium /usr/bin/chromium-browser

# Chromium/Puppeteer: evitar download e apontar pro SO
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
ENV PUPPETEER_SKIP_DOWNLOAD=1
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROME_PATH=/usr/bin/chromium

# ==== 2) Python venv + yt-dlp (binário confiável) ====
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install -U "yt-dlp[default]"

# ==== 3) Versões PINNED das libs Node (compatíveis entre si) ====
# ATENÇÃO:
# - http-cookie-agent@5.x + tough-cookie@4.x (mantém export HttpCookieAgent)
# - jsdom@22.x (usa tough-cookie 4, evitando conflito da v27 que pede 6)
# - axios-cookiejar-support@6.x é compatível com tough-cookie>=4
# - puppeteer não baixa Chromium (usamos do SO)
ARG PUPPETEER_VERSION=22.15.0
ARG LIGHTHOUSE_VERSION=12.1.0
ARG AXIOS_VERSION=1.7.7
ARG ICONV_VERSION=0.6.3
ARG JSDOM_VERSION=22.1.0
ARG TOUGH_COOKIE_VERSION=4.1.4
ARG COOKIE_AGENT_VERSION=5.0.3
ARG PLURALIZE_VERSION=8.0.0
ARG IMAP_VERSION=0.8.19
ARG MAILPARSER_VERSION=3.9.0

# 3.1) Instalação LOCAL (Function Nodes procuram em /data/node_modules)
RUN npm install \
    puppeteer@${PUPPETEER_VERSION} \
    lighthouse@${LIGHTHOUSE_VERSION} \
    axios@${AXIOS_VERSION} \
    iconv-lite@${ICONV_VERSION} \
    jsdom@${JSDOM_VERSION} \
    pluralize@${PLURALIZE_VERSION} \
    axios-cookiejar-support@6.0.4 \
    tough-cookie@${TOUGH_COOKIE_VERSION} \
    imap@${IMAP_VERSION} \
    mailparser@${MAILPARSER_VERSION} \
    http-cookie-agent@${COOKIE_AGENT_VERSION} \
    --prefix /data

# 3.2) Instalação GLOBAL (Task Runner resolve primeiro o escopo dele; garanta presença global)
RUN npm install -g \
    puppeteer@${PUPPETEER_VERSION} \
    lighthouse@${LIGHTHOUSE_VERSION} \
    axios@${AXIOS_VERSION} \
    iconv-lite@${ICONV_VERSION} \
    jsdom@${JSDOM_VERSION} \
    pluralize@${PLURALIZE_VERSION} \
    axios-cookiejar-support@6.0.4 \
    tough-cookie@${TOUGH_COOKIE_VERSION} \
    imap@${IMAP_VERSION} \
    mailparser@${MAILPARSER_VERSION} \
    http-cookie-agent@${COOKIE_AGENT_VERSION}

# 3.3) ytdl-core global (usado em vários nodes)
RUN npm install -g ytdl-core@latest

# 3.4) yt-dlp wrapper Node + alias para "yt-dlp-exec"
RUN npm install -g yt-dlp-wrap && \
    mkdir -p /usr/local/lib/node_modules/yt-dlp-exec && \
    echo "module.exports = require('yt-dlp-wrap');" > /usr/local/lib/node_modules/yt-dlp-exec/index.js

# 3.5) (Opcional) pluralize global redundante (alguns flows esperam global)
RUN npm install -g pluralize@${PLURALIZE_VERSION}

# ==== 4) Scripts auxiliares (lighthouse runner etc.) ====
RUN mkdir -p /data/scripts && \
    git clone https://github.com/vixon-dev/n8n.git /tmp/n8n && \
    cp /tmp/n8n/scripts/lighthouse-runner.mjs /data/scripts/lighthouse-runner.mjs && \
    cp /tmp/n8n/scripts/update-scripts.sh /data/scripts/update-scripts.sh && \
    chmod +x /data/scripts/update-scripts.sh && \
    rm -rf /tmp/n8n
RUN chown -R root:node /data/scripts && chmod -R 770 /data/scripts

# ==== 5) Diretórios e permissões ====
RUN mkdir -p /data/n8n && chown node:node /data/n8n && chmod u+rwx /data/n8n
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n && chmod 700 /home/node/.n8n
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# ==== 6) Permissões para uso das libs nos Function Nodes ====
ENV NODE_FUNCTION_ALLOW_BUILTIN=*
ENV NODE_FUNCTION_ALLOW_EXTERNAL=\
ytdl-core,yt-dlp-exec,yt-dlp-wrap,\
puppeteer,lighthouse,axios,iconv-lite,jsdom,pluralize,\
axios-cookiejar-support,tough-cookie,imap,mailparser,http-cookie-agent

# ==== 7) NODE_PATH para facilitar resolução (Function Node e Task Runner) ====
ENV NODE_PATH=/data/node_modules:/usr/local/lib/node_modules:/usr/local/lib/node_modules/n8n/dist/node_modules:/usr/local/lib/node_modules/n8n/node_modules:/usr/local/lib/node_modules:/usr/local/node_modules:/usr/node_modules:/node_modules

# ==== 8) Sanity checks (falha o build se algo incompatível aparecer) ====
# Verifica se o export existe (evita o erro "does not provide an export named HttpCookieAgent")
RUN node -e "const e=require('http-cookie-agent/http'); if(!e.HttpCookieAgent){console.error('HttpCookieAgent export ausente!'); process.exit(1);} console.log('HttpCookieAgent OK');" \
 && node -e "console.log('http-cookie-agent',require('http-cookie-agent/package.json').version)" \
 && node -e "console.log('tough-cookie',require('tough-cookie/package.json').version)" \
 && node -e "console.log('jsdom',require('jsdom/package.json').version)"

# ==== 9) Ajustes n8n futuros/avisos ====
# Evitar futuros avisos e falhas por default changes:
ENV DB_SQLITE_POOL_SIZE=1
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=false

# Chromium flags úteis em ambientes containerizados (use nos flows lighthouse/puppeteer)
ENV CHROME_FLAGS="--headless=new --no-sandbox --disable-dev-shm-usage --disable-gpu"

# ==== 10) Usuário e workdir ====
USER node
WORKDIR /data
