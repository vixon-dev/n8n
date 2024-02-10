# Usar a imagem oficial do n8n como base
FROM n8nio/n8n

# Altera para root para instalar as dependências
USER root
# Instalar YTDL
RUN npm install -g ytdl-core
# Instalar FFMPEG e PHP
RUN apk add ffmpeg php
# Instalar PYTHON
RUN apk add --update python3 py3-pip
# Volta para o user node
USER node

# Definir o diretório de trabalho
WORKDIR /data
