# Usar a imagem oficial do n8n como base com a tag `latest`
FROM n8nio/n8n:next

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
    font-noto-cjk

# Instalar Puppeteer e Lighthouse globalmente
RUN npm install -g puppeteer \
    && npm install -g lighthouse

# Cria um ambiente virtual e ativa-o
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Instala a versão mais recente do yt-dlp dentro do ambiente virtual
RUN pip install -U "yt-dlp[default]"

# Instala a versão mais recente do ytdl-core
RUN npm install -g ytdl-core@latest
RUN npm i youtube-transcript

# Permite usar ytdl-core, puppeteer, lighthouse e outras bibliotecas nos Function Nodes
ENV NODE_FUNCTION_ALLOW_BUILTIN=*
ENV NODE_FUNCTION_ALLOW_EXTERNAL=ytdl-core,yt-dlp,puppeteer,lighthouse

# Define variáveis de ambiente necessárias
ENV NODE_PATH=/usr/local/lib/node_modules

# Volta para o user node
USER node

# Definir o diretório de trabalho
WORKDIR /data
