const puppeteer = require('puppeteer');
const lighthouse = require('lighthouse');
const { URL } = require('url');
const axios = require('axios');

// Função principal para rodar o Lighthouse
async function runLighthouse(url) {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--remote-debugging-port=9222']
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

// URL do webhook do N8N para enviar os resultados
const webhookUrl = process.argv[3];
if (!webhookUrl) {
  console.error("Por favor, forneça o Webhook do N8N.");
  process.exit(1);
}

// Executa o Lighthouse e envia o relatório para o Webhook
runLighthouse(url).then(report => {
  const data = {
    performance: report.categories.performance.score,
    accessibility: report.categories.accessibility.score,
    bestPractices: report.categories['best-practices'].score,
    seo: report.categories.seo.score,
    pwa: report.categories.pwa.score
  };

  // Envia os resultados para o webhook do N8N
  axios.post(webhookUrl, data)
    .then(response => {
      console.log('Relatório enviado com sucesso:', response.data);
    })
    .catch(error => {
      console.error('Erro ao enviar os dados:', error);
    });
}).catch(error => {
  console.error('Erro ao executar o Lighthouse:', error);
});
