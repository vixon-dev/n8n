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
    font-noto-cjk \
    git \
    nano

# Instala o Puppeteer, Lighthouse, Axios, Iconv-lite e outros pacotes diretamente no diretório /data
RUN npm install puppeteer lighthouse axios url iconv-lite jsdom --prefix /data

# Cria um ambiente virtual e ativa-o
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Instala a versão mais recente do yt-dlp dentro do ambiente virtual
RUN pip install -U "yt-dlp[default]"

# Instala a versão mais recente do ytdl-core
RUN npm install -g ytdl-core@latest
RUN npm install youtube-transcript --prefix /data

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

# Permite usar ytdl-core, puppeteer, lighthouse, axios, iconv-lite e outras bibliotecas nos Function Nodes
ENV NODE_FUNCTION_ALLOW_BUILTIN=*
ENV NODE_FUNCTION_ALLOW_EXTERNAL=ytdl-core,yt-dlp,puppeteer,lighthouse,axios,url,iconv-lite,jsdom

# Define variáveis de ambiente necessárias para que o Node.js saiba onde encontrar os módulos instalados
ENV NODE_PATH=/data/node_modules

# Volta para o user node
USER node

# Definir o diretório de trabalho
WORKDIR /data
