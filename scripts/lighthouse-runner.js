import puppeteer from 'puppeteer';
import { lighthouse } from 'lighthouse';
import { URL } from 'url';
import axios from 'axios';

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

// URL do webhook do N8N para enviar os resultados, opcional
const webhookUrl = process.argv[3];

// Executa o Lighthouse e trata o relatório
runLighthouse(url).then(report => {
  const data = {
    performance: report.categories.performance.score,
    accessibility: report.categories.accessibility.score,
    bestPractices: report.categories['best-practices'].score,
    seo: report.categories.seo.score,
    pwa: report.categories.pwa.score
  };

  // Se a URL do webhook foi fornecida, envia o resultado para o Webhook
  if (webhookUrl) {
    axios.post(webhookUrl, data)
      .then(response => {
        console.log('Relatório enviado com sucesso:', response.data);
      })
      .catch(error => {
        console.error('Erro ao enviar os dados:', error);
      });
  } else {
    // Se não houver webhook, imprime o JSON no console
    console.log(JSON.stringify(data, null, 2));
  }

}).catch(error => {
  console.error('Erro ao executar o Lighthouse:', error);
});
