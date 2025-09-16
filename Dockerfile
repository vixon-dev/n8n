# Version: 1.111.0 (k)
FROM n8nio/n8n:1.111.0

###############################
# 1. Permissões root
###############################
USER root

###############################
# 2. Dependências do sistema
###############################
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
    sqlite \
 && ln -sf /usr/bin/chromium /usr/bin/chromium-browser

###############################
# 3. Python / yt-dlp
###############################
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install -U "yt-dlp[default]"

###############################
# 4. Variáveis de versão (fixadas)
###############################
ARG PUPPETEER_VERSION=22.15.0
ARG LIGHTHOUSE_VERSION=12.1.0
ARG AXIOS_VERSION=1.7.7
ARG ICONV_VERSION=0.6.3
ARG JSDOM_VERSION=22.1.0
ARG PLURALIZE_VERSION=8.0.0
ARG TOUGH_COOKIE_VERSION=4.1.4
ARG IMAP_VERSION=0.8.19
ARG MAILPARSER_VERSION=3.7.1     # fixado, pois 3.9.0 não existe
ARG COOKIE_AGENT_VERSION=5.0.3

###############################
# 5. Instalação de libs Node.js
###############################
# 5.1) Local (para Function Nodes)
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
    --prefix /data --legacy-peer-deps

# 5.2) Global (para Task Runners / Workers)
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
    http-cookie-agent@${COOKIE_AGENT_VERSION} \
    --legacy-peer-deps

###############################
# 6. Extras (multimídia / transcripts)
###############################
RUN npm install -g ytdl-core@latest youtube-transcript-api

###############################
# 7. Segurança: volta para usuário do n8n
###############################
USER node
WORKDIR /data

###############################
# 8. Entrypoint
###############################
CMD ["n8n"]
