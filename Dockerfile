# Usar a imagem oficial do n8n como base com a tag `latest`
FROM n8nio/n8n:next

# Altera para root para instalar as dependências
USER root

# Atualiza os índices dos pacotes e instala FFMPEG, PHP, e Python
RUN apk update && apk add ffmpeg php python3 py3-pip

# Instala a versão mais recente do ytdl-core
RUN npm install -g ytdl-core@latest

# Permite usar ytdl-core e outras bibliotecas nos Function Nodes
ENV NODE_FUNCTION_ALLOW_EXTERNAL=ytdl-core

# Define variáveis de ambiente necessárias
ENV NODE_PATH=/usr/local/lib/node_modules

# Volta para o user node
USER node

# Definir o diretório de trabalho
WORKDIR /data
