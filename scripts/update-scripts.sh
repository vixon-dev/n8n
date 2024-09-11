#!/bin/bash

# Diretório onde os scripts .js estão armazenados no servidor
SCRIPTS_DIR="/data/scripts"

# Repositório GitHub contendo os scripts
REPO_URL="https://github.com/vixon-dev/n8n.git"

# Diretório temporário para clonar o repositório
TMP_DIR="/tmp/n8n-repo"

# Limpa qualquer diretório temporário anterior
rm -rf "$TMP_DIR"

# Clona o repositório GitHub para o diretório temporário
git clone "$REPO_URL" "$TMP_DIR"

# Copia os arquivos .js do repositório para o diretório /data/scripts
cp "$TMP_DIR/scripts/"*.js "$SCRIPTS_DIR"

# Limpa o diretório temporário
rm -rf "$TMP_DIR"

echo "Scripts atualizados com sucesso do repositório GitHub."
