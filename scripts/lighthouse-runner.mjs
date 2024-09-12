import puppeteer from 'puppeteer';
import lighthouse from 'lighthouse';
import { URL } from 'url';
import axios from 'axios';

// Função principal para rodar o Lighthouse
async function runLighthouse(url) {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/chromium-browser',  // Caminho do Chromium no Alpine Linux
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const { lhr } = await lighthouse(url, {
    port: new URL(browser.wsEndpoint()).port,
    output: 'json',
    logLevel: 'info',
  });

  await browser.close();

  return lhr;
}

// Receber a URL como argumento
const url = process.argv[2];
if (!url) {
  console.error("Por favor, forneça uma URL para analisar.");
  process.exit(1);
}

// URL do webhook do N8N para enviar os resultados, opcional
const webhookUrl = process.argv[3];

// Executa o Lighthouse e trata o relatório
runLighthouse(url).then(report => {
  // Se a URL do webhook foi fornecida, envia o resultado completo para o Webhook
  if (webhookUrl) {
    axios.post(webhookUrl, report)
      .then(response => {
        console.log('Relatório completo enviado com sucesso:', response.data);
      })
      .catch(error => {
        console.error('Erro ao enviar os dados:', error);
      });
  } else {
    // Se não houver webhook, imprime o relatório completo no console
    console.log(JSON.stringify(report, null, 2));
  }

}).catch(error => {
  console.error('Erro ao executar o Lighthouse:', error);
});
