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
    // Focar apenas nas categorias relevantes
    onlyCategories: ['performance', 'seo', 'best-practices', 'accessibility'], // Incluindo acessibilidade para mobile
    // Configurações para otimizar o tempo de execução
    disableStorageReset: true,  // Não limpa o armazenamento local do navegador
    throttlingMethod: 'provided',  // Usa a configuração de throttling do navegador
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
    seo: {
      score: report.categories.seo.score,
      meta_description: report.audits['meta-description']?.score || 'N/A',
      http_status: report.audits['is-on-https']?.score || 'N/A',
      hreflang: report.audits['hreflang']?.score || 'N/A',
      title_tag: report.audits['document-title']?.score || 'N/A',
      headings_structure: report.audits['heading-order']?.score || 'N/A',
      robots_txt: report.audits['robots-txt']?.score || 'N/A',
      canonical_tag: report.audits['canonical']?.score || 'N/A',
      structured_data: report.audits['structured-data']?.score || 'N/A',
      crawlable_links: report.audits['crawlable-anchors']?.score || 'N/A'
    },
    performance: {
      score: report.categories.performance.score,
      first_contentful_paint: report.audits['first-contentful-paint']?.numericValue || 'N/A',
      largest_contentful_paint: report.audits['largest-contentful-paint']?.numericValue || 'N/A',
      time_to_interactive: report.audits['interactive']?.numericValue || 'N/A',
      total_blocking_time: report.audits['total-blocking-time']?.numericValue || 'N/A',
      cumulative_layout_shift: report.audits['cumulative-layout-shift']?.numericValue || 'N/A',
      speed_index: report.audits['speed-index']?.numericValue || 'N/A',
      time_to_first_byte: report.audits['server-response-time']?.numericValue || 'N/A',
      render_blocking_resources: report.audits['render-blocking-resources']?.score || 'N/A',
      lazy_load_images: report.audits['offscreen-images']?.score || 'N/A'
    },
    best_practices: {
      score: report.categories['best-practices']?.score || 'N/A',
      uses_https: report.audits['is-on-https']?.score || 'N/A',
      vulnerabilities: report.audits['no-vulnerable-libraries']?.score || 'N/A',
      csp: report.audits['csp-xss']?.score || 'N/A',
      uses_passive_listeners: report.audits['uses-passive-event-listeners']?.score || 'N/A'
    },
    mobile: {
      score: report.categories['accessibility']?.score || 'N/A', // Avalia a usabilidade em mobile
      viewport: report.audits['viewport']?.score || 'N/A',
      mobile_friendly: report.audits['mobile-friendly']?.score || 'N/A',
      touch_targets: report.audits['tap-targets']?.score || 'N/A',
      font_legibility: report.audits['font-size']?.score || 'N/A',  // Fontes legíveis para mobile
      image_aspect_ratio: report.audits['image-aspect-ratio']?.score || 'N/A'  // Imagens com proporção correta
    }
  };

  // Enviar via webhook ou imprimir no console
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
