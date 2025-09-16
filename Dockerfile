# Latest Version: 1.111.0 (g)
FROM n8nio/n8n:1.111.0

# Altera para root para instalar as dependências
USER root

# Atualiza os índices dos pacotes e instala FFMPEG, PHP, Python e dependências do Chromium
RUN apk update && \
    apk add --no-cache \
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
    bash

# Instala pacotes diretamente no diretório /data (para Function Nodes normais)
RUN npm install puppeteer lighthouse axios url iconv-lite jsdom pluralize \
    axios-cookiejar-support tough-cookie imap mailparser http-cookie-agent@6.0.0 \
    --prefix /data

# Instala pacotes globalmente (para Task Runners não darem MODULE_NOT_FOUND)
RUN npm install -g puppeteer lighthouse axios iconv-lite jsdom pluralize \
    axios-cookiejar-support tough-cookie imap mailparser http-cookie-agent@6.0.0

# Instalação global do pluralize para garantir que ele seja acessível
RUN npm install -g pluralize

# Cria um ambiente virtual Python e ativa-o
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Instala a versão mais recente do yt-dlp dentro do ambiente virtual (Python)
RUN pip install -U "yt-dlp[default]"

# Instala a versão mais recente do ytdl-core (Node.js)
RUN npm install -g ytdl-core@latest

# Instala youtube-transcript-api local e global (para Function Nodes e Task Runners)
RUN npm install youtube-transcript-api --prefix /data
RUN npm install -g youtube-transcript-api

# Instala yt-dlp-wrap e cria um alias para funcionar como yt-dlp-exec
RUN npm install -g yt-dlp-wrap && \
    mkdir -p /usr/local/lib/node_modules/yt-dlp-exec && \
    echo "module.exports = require('yt-dlp-wrap');" > /usr/local/lib/node_modules/yt-dlp-exec/index.js

# Baixa os scripts lighthouse-runner.mjs e update-scripts.sh do GitHub e salva em /data/scripts/
RUN mkdir -p /data/scripts && \
    git clone https://github.com/vixon-dev/n8n.git /tmp/n8n && \
    cp /tmp/n8n/scripts/lighthouse-runner.mjs /data/scripts/lighthouse-runner.mjs && \
    cp /tmp/n8n/scripts/update-scripts.sh /data/scripts/update-scripts.sh && \
    chmod +x /data/scripts/update-scripts.sh && \
    rm -rf /tmp/n8n

# Definir permissões apenas para root e node no diretório /data/scripts
RUN chown -R root:node /data/scripts && \
    chmod -R 770 /data/scripts

# Cria a pasta iset-token no diretório /data e define permissões de escrita para o usuário node
RUN mkdir -p /data/n8n && \
    chown node:node /data/n8n && \
    chmod u+rwx /data/n8n

# Permite usar libs nos Function Nodes e Task Runners
ENV NODE_FUNCTION_ALLOW_BUILTIN=*
ENV NODE_FUNCTION_ALLOW_EXTERNAL=ytdl-core,yt-dlp-exec,yt-dlp-wrap,puppeteer,lighthouse,axios,url,iconv-lite,jsdom,pluralize,axios-cookiejar-support,tough-cookie,imap,mailparser,http-cookie-agent,youtube-transcript-api

# Aqui, garantimos que o caminho /data/node_modules seja incluído no NODE_PATH
ENV NODE_PATH=/data/node_modules:/usr/local/lib/node_modules:/usr/local/lib/node_modules/n8n/dist/node_modules:/usr/local/lib/node_modules/n8n/node_modules:/usr/local/lib/node_modules:/usr/local/node_modules:/usr/node_modules:/node_modules

# Volta para o user node
USER node

# Definir o diretório de trabalho
WORKDIR /data
