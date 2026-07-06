% =========================================================================
% APII - Simulação de Comunicações Móveis I
% Equipe 03 | Matrícula Responsável: 603573
% MATHEUS MARCELO COSTA DE SOUZA | DIOGO DE OLIVEIRA SOARES 
% ERIK RAY BARBOSA FALCÃO | ICARO RYAN BARBOSA FALCÃO
% =========================================================================

% Limpeza do ambiente
clear; clc; close all;

% Configuração da semente de números aleatórios
matricula = 603573;
rng(matricula);

% =========================================================================
% Parâmetros do Sistema
% =========================================================================

% -------------------------------------------------------------------------
% Parâmetros Individuais - Tabela 3 (Dígito final 3)
% -------------------------------------------------------------------------
n_PL = 3.0;              % Expoente de perda de percurso (adimensional)
sigma_sh_dB = 8;         % Desvio padrão do sombreamento log-normal (dB)
N_I = 4;                 % Número de interferentes ativos co-canal
fator_reuso = 3;         % Fator de reuso de frequência
ue_ref = 'UE-D';         % Usuário de referência atribuído à equipe

% -------------------------------------------------------------------------
% Parâmetros Fixos - Tabela 2
% -------------------------------------------------------------------------
P_tx_dBm = 40;           % Potência de transmissão da Estação Base (dBm)
PL_0_dB = 30;            % Perda de referência (dB)
d_0_m = 1;               % Distância de referência (metros)
d_0_km = d_0_m / 1000;   % Distância de referência convertida para (km)
B_Hz = 10e6;             % Largura de banda (10 MHz convertido para Hz)
N0_dBm_Hz = -174;        % Densidade espectral de ruído térmico (dBm/Hz)
NF_dB = 7;               % Figura de ruído do receptor (dB)

% =========================================================================
% ITEM 1: Definição e Plotagem do Cenário (Grade Hexagonal e Usuários)
% =========================================================================

% Parâmetros Geométricos Básicos
R = 1;                  % Raio da célula em km (inferido da Figura 1)
D = sqrt(3) * R;        % Distância inter-site (entre centros das células)

% -------------------------------------------------------------------------
% 1. Posicionamento das Estações Base (BS0 a BS6)
% -------------------------------------------------------------------------
% BS0 está na origem. As demais formam um anel ao redor.
angulos_BS = (0:5) * (pi/3); % [0, 60, 120, 180, 240, 300] em radianos
BS_x = [0, D * cos(angulos_BS)]; 
BS_y = [0, D * sin(angulos_BS)];

% -------------------------------------------------------------------------
% 2. Geometria da Grade Hexagonal (Para plotagem e limites)
% -------------------------------------------------------------------------
% Definindo os vértices de um hexágono com "topo pontiagudo" centrado na origem
angulos_hex = (pi/6) : (pi/3) : (2*pi + pi/6);
hex_base_x = R * cos(angulos_hex);
hex_base_y = R * sin(angulos_hex);

% -------------------------------------------------------------------------
% 3. Distribuição Uniforme de Usuários (N_UE) na Área de Cobertura
% -------------------------------------------------------------------------
N_UE = 300; % Quantidade de usuários para visualização no Item 1 
UE_x = zeros(1, N_UE);
UE_y = zeros(1, N_UE);

% Espalhando uniformemente dentro da célula central (BS0) usando Rejeição
cont_ue = 1;
while cont_ue <= N_UE
    % Gera pontos aleatórios num quadrado que circunscreve o hexágono
    px = (rand() - 0.5) * 2 * R;
    py = (rand() - 0.5) * 2 * R;
    
    % Se o ponto gerado cair dentro dos limites do hexágono, nós o salvamos
    if inpolygon(px, py, hex_base_x, hex_base_y)
        UE_x(cont_ue) = px;
        UE_y(cont_ue) = py;
        cont_ue = cont_ue + 1;
    end
end

% Coordenadas exatas do seu Usuário de Referência (UE-D) extraídas da Tabela 1
UE_D_x = -0.32; 
UE_D_y = -0.38;

% -------------------------------------------------------------------------
% 4. Plotagem Completa do Cenário
% -------------------------------------------------------------------------
figure; hold on; grid on; axis equal;
axis([-3 3 -3 3]);
xlabel('Posição x (km)');
ylabel('Posição y (km)');
title('Cenário de Simulação - Equipe 03');

% Desenha a grade hexagonal de todas as 7 células
for i = 1:7
    plot(BS_x(i) + hex_base_x, BS_y(i) + hex_base_y, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2);
end

% Preenche a célula central com azul claro para destacar a área de cobertura
fill(hex_base_x, hex_base_y, [0.8509 0.9098 0.9608], 'EdgeColor', [0.6 0.6 0.6]);

% Plota a nuvem de usuários uniformes (pontos pequenos e cinzas)
scatter(UE_x, UE_y, 8, [0.7 0.7 0.7], 'filled', 'MarkerEdgeAlpha', 0.5); 

% Plota as Estações Base
scatter(BS_x(1), BS_y(1), 120, '^', 'filled', 'MarkerFaceColor', [0 0.447 0.741], 'MarkerEdgeColor', 'k'); % BS0
scatter(BS_x(2:end), BS_y(2:end), 120, '^', 'filled', 'MarkerFaceColor', [0.85 0.325 0.098], 'MarkerEdgeColor', 'k'); % BS1-6

% Plota o seu Usuário de Referência UE-D (Estrela grande e verde)
plot(UE_D_x, UE_D_y, 'p', 'MarkerSize', 14, 'MarkerFaceColor', [0.2 0.8 0.2], 'MarkerEdgeColor', 'k');

% Rótulos de Texto
text(BS_x(1), BS_y(1) - 0.2, 'BS0', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
for i = 2:7
    text(BS_x(i), BS_y(i) + 0.2, sprintf('BS%d', i-1), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end
text(UE_D_x, UE_D_y - 0.15, 'UE-D', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.2 0.8 0.2]);

% Traça o enlace desejado (BS0 -> UE-D)
plot([BS_x(1), UE_D_x], [BS_y(1), UE_D_y], '-', 'Color', [0 0.447 0.741], 'LineWidth', 1.5);

legend('Borda das Células', 'Área de Cobertura Central', 'Usuários Uniformes (N_{UE})', ...
       'BS0 (Servidora)', 'BS1-BS6 (Interferentes)', 'UE-D (Referência)', 'Enlace Desejado', ...
       'Location', 'eastoutside');
hold off;



% =========================================================================
% ITEM 2: Perda de Percurso (Path Loss) para TODOS os pares Tx/Rx
% =========================================================================

% 1. Alocação de memória para as matrizes [7 BSs x N_UE usuários]
dist_BS_UE_km = zeros(7, N_UE);
PL_BS_UE_dB   = zeros(7, N_UE);

% 2. Cálculo em massa para a nuvem de usuários (N_UE)
for b = 1:7
    % Distância da Estação Base 'b' para todos os usuários simultaneamente
    dist_BS_UE_km(b, :) = sqrt((UE_x - BS_x(b)).^2 + (UE_y - BS_y(b)).^2);
    
    % Chamada da função para calcular o Path Loss (vetorizado)
    PL_BS_UE_dB(b, :) = calcula_path_loss(dist_BS_UE_km(b, :), d_0_km, PL_0_dB, n_PL);
end

% 3. Cálculo para o Usuário de Referência (UE-D) contra todas as 7 BSs
dist_BS_UED_km = zeros(7, 1);
PL_BS_UED_dB   = zeros(7, 1);

for b = 1:7
    dist_BS_UED_km(b) = sqrt((UE_D_x - BS_x(b))^2 + (UE_D_y - BS_y(b))^2);
    PL_BS_UED_dB(b)   = calcula_path_loss(dist_BS_UED_km(b), d_0_km, PL_0_dB, n_PL);
end

% 4. Validação contra o valor calculado manualmente (Prova Real)
fprintf('\n===================================================\n');
fprintf('ITEM 2: CÁLCULO E VALIDAÇÃO DA PERDA DE PERCURSO\n');
fprintf('===================================================\n');
fprintf('Malha processada: %d enlaces Tx/Rx calculados.\n\n', 7 * N_UE);
fprintf('--- PROVA REAL DA FUNÇÃO (Baseado no UE-D) ---\n');
fprintf('Par Tx/Rx                : BS0 -> UE-D\n');
fprintf('Distância Simulada (d)   : %.4f km\n', dist_BS_UED_km(1));
fprintf('Path Loss Simulado (PL)  : %.2f dB\n', PL_BS_UED_dB(1));
fprintf('===================================================\n\n');


% =========================================================================
% ITEM 3: Sombreamento Log-Normal (Shadowing) e Validação Estatística
% =========================================================================

% 1. Geração do Sombreamento
% Gera matriz de sombreamento para todas as 7 BSs e a nuvem de N_UE usuários
sh_BS_UE_dB = gera_sombreamento(sigma_sh_dB, 7, N_UE);

% Gera o sombreamento para o seu usuário de referência (UE-D)
sh_BS_UED_dB = gera_sombreamento(sigma_sh_dB, 7, 1);

% 2. Verificação Empírica vs Teórica (Plotagem)
% Para a estatística fazer sentido, pegamos todos os valores gerados na
% matriz sh_BS_UE_dB (7 x 300) e transformamos em um único vetor (2100 amostras)
amostras_sh = sh_BS_UE_dB(:);

figure; hold on; grid on;
title('Item 3: Verificação do Sombreamento Log-Normal (escala em dB)');
xlabel('Atenuação de Sombreamento (dB)');
ylabel('Densidade de Probabilidade (PDF)');

% Plotagem Empírica: Histograma dos dados simulados (normalizado para PDF)
histogram(amostras_sh, 'Normalization', 'pdf', 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'w');

% Plotagem Teórica: Curva da Função Densidade de Probabilidade (PDF) Gaussiana
% Criamos um eixo X teórico varrendo do menor ao maior valor gerado
x_teorico = linspace(min(amostras_sh) - 5, max(amostras_sh) + 5, 200);

% Aplicação da equação matemática da PDF Normal (média 0, desvio sigma_sh_dB)
pdf_teorica = (1 / (sigma_sh_dB * sqrt(2*pi))) * exp(-(x_teorico.^2) / (2 * sigma_sh_dB^2));

% Plota a curva teórica por cima do histograma
plot(x_teorico, pdf_teorica, 'LineWidth', 2.5, 'Color', [0.85 0.325 0.098]);

legend('Distribuição Empírica (Simulação)', 'Distribuição Teórica (Equação Matemática)', 'Location', 'best');
hold off;

% 3. Imprime uma validação rápida no console para o UE-D
fprintf('ITEM 3: GERAÇÃO DE SOMBREAMENTO CONCLUÍDA\n');
fprintf('Amostras geradas e validadas: %d\n', length(amostras_sh));
fprintf('Sombreamento gerado para BS0 -> UE-D: %.2f dB\n', sh_BS_UED_dB(1));
fprintf('===================================================\n\n');



% =========================================================================
% ITEM 4: Desvanecimento Rápido (Rayleigh Fading) e Validação Estatística
% =========================================================================

% 1. Geração do Canal para Validação (Amostragem grande)
N_amostras_fading = 100000;
h_fading = gera_fast_fading(1, N_amostras_fading);

% 2. Extração das Métricas Empíricas
envelope_empirico = abs(h_fading);       % Magnitude |h|
potencia_empirica = abs(h_fading).^2;    % Potência |h|^2

% ==================== PLOTAGEM A: ENVELOPE |h| ====================
figure; 
subplot(1, 2, 1); hold on; grid on;
title('Desvanecimento: Envelope |h| (Rayleigh)');
xlabel('Amplitude'); ylabel('PDF');

% Empírico: Histograma normalizado
histogram(envelope_empirico, 'Normalization', 'pdf', 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'w');

% Teórico: PDF da Distribuição de Rayleigh (sigma = sqrt(0.5))
x_ray = linspace(0, max(envelope_empirico), 100);
sigma_ray = sqrt(0.5);
pdf_ray_teorica = (x_ray / sigma_ray^2) .* exp(-(x_ray.^2) / (2 * sigma_ray^2));
plot(x_ray, pdf_ray_teorica, 'LineWidth', 2.5, 'Color', [0 0.447 0.741]);

legend('Empírica (Simulada)', 'Teórica (Rayleigh)', 'Location', 'best');

% ==================== PLOTAGEM B: POTÊNCIA |h|^2 ====================
subplot(1, 2, 2); hold on; grid on;
title('Desvanecimento: Potência |h|^2 (Exponencial)');
xlabel('Potência (Linear)'); ylabel('PDF');

% Empírico: Histograma normalizado
histogram(potencia_empirica, 'Normalization', 'pdf', 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'w');

% Teórico: PDF da Distribuição Exponencial (média = 1)
x_exp = linspace(0, max(potencia_empirica), 100);
pdf_exp_teorica = exp(-x_exp);
plot(x_exp, pdf_exp_teorica, 'LineWidth', 2.5, 'Color', [0.85 0.325 0.098]);

legend('Empírica (Simulada)', 'Teórica (Exponencial)', 'Location', 'best');
sgtitle('Item 4: Validação do Desvanecimento Rápido (Fast Fading)');

% 3. Imprime a validação de potência no console
fprintf('ITEM 4: GERAÇÃO DE DESVANECIMENTO RÁPIDO\n');
fprintf('Distribuição Escolhida : Rayleigh\n');
fprintf('Potência Média Teórica : 1.0000\n');
fprintf('Potência Média Simulada: %.4f\n', mean(potencia_empirica));
fprintf('===================================================\n\n');


% =========================================================================
% ITEM 5: Ilustracao das Componentes do Canal
% =========================================================================

% 1. Configuração do Percurso Linear (Vetor de Distância)
% Gerando um percurso de 1 a 1000 metros (passos de 1m) para a simulação do canal
d = 1:1:1000; 
N_amostras = length(d);

% -------------------------------------------------------------------------
% Componente 1: Perda de Percurso (Path Loss - Tendência Média)
% -------------------------------------------------------------------------
% Aplicação da Eq. (1)
PL = PL_0_dB + 10 * n_PL * log10(d / d_0_m);
P_rx_avg = P_tx_dBm - PL; % Potência média recebida (apenas perda de percurso)

% -------------------------------------------------------------------------
% Componente 2: Sombreamento Log-Normal (Variação Lenta Correlacionada)
% -------------------------------------------------------------------------
% Para que seja visualmente identificável como uma variação "lenta",
% aplica-se o Modelo de Correlação Espacial de Gudmundson.
delta_d = 1;      % Espaçamento entre as amostras (1 metro)
d_cor = 50;       % Distância de correlação típica urbana (50 metros)
rho = exp(-delta_d / d_cor); % Fator de correlação entre amostras adjacentes

% Inicialização do vetor de sombreamento
X_sigma = zeros(1, N_amostras);

% Amostra inicial gerada a partir da distribuição normal com desvio da main (sigma_sh_dB)
X_sigma(1) = sigma_sh_dB * randn(); 

% Processo autoregressivo de primeira ordem (AR-1) para impor a correlação espacial
for k = 2:N_amostras
    X_sigma(k) = rho * X_sigma(k-1) + sqrt(1 - rho^2) * sigma_sh_dB * randn();
end

% Potência de larga escala (Atenuação Média + Obstáculos)
P_rx_large_scale = P_rx_avg - X_sigma; 

% -------------------------------------------------------------------------
% Componente 3: Desvanecimento Rápido (Fast Fading Rayleigh - Pequena Escala)
% -------------------------------------------------------------------------
% Gerando componentes em fase (I) e quadratura (Q) independentes, Eq. (4)
h_I = randn(1, N_amostras) / sqrt(2);
h_Q = randn(1, N_amostras) / sqrt(2);
h_mag = sqrt(h_I.^2 + h_Q.^2); % Envelope Rayleigh
h_power = h_mag.^2;            % Ganho de potência instantânea (Exponencial)

% Potência Total Recebida (Combinando as 3 camadas do canal), Eq. (5)
P_rx_total = P_rx_large_scale + 10 * log10(h_power);

% -------------------------------------------------------------------------
% Geração do Gráfico Qualitativo (Figure 1)
% -------------------------------------------------------------------------
figure(1);
plot(d, P_rx_total, 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8); hold on;
plot(d, P_rx_large_scale, 'b', 'LineWidth', 1.8);
plot(d, P_rx_avg, 'r', 'LineWidth', 2.2);
hold off;

% Formatação e Identificação Visual Exigida no PDF
grid on;
title(sprintf('Ilustração Qualitativa das Componentes do Canal (Matrícula Final 3: n = %.1f, \\sigma_{sh} = %d dB)', n_PL, sigma_sh_dB));
xlabel('Distância entre Transmissor e Receptor (m)');
ylabel('Potência Recebida (dBm)');
legend('Sinal Total (Path Loss + Sombreamento + Desvanecimento Rápido)', ...
       'Larga Escala (Path Loss + Sombreamento)', ...
       'Tendência Média (Apenas Path Loss)', ...
       'Location', 'southwest');

% Ajuste de limites para melhor visualização
xlim([0 1000]);
ylim([min(P_rx_total)-5, max(P_rx_total)+5]);


% =========================================================================
% ITEM 6: Calculo da Potencia
% =========================================================================

% Geração da matriz de desvanencimento:
h_fading_matriz = gera_fast_fading(7, N_UE);

P_rx_linear = calcula_potencia_rx(P_tx_dBm, PL_BS_UE_dB, sh_BS_UE_dB, h_fading_matriz);

% =========================================================================
% ITEM 7: Cálculo da SINR
% =========================================================================

% Cálculo do Ruído:
N0_linear = 10^((N0_dBm_Hz + NF_dB) / 10); 
P_ruido = N0_linear * B_Hz;

[SINR_lin, SINR_dB_vetor] = calcula_sinr(P_rx_linear, P_ruido, N_I);

% PRINT
fprintf('ITEM 7: Cálculo da SINR\n');
fprintf('SINR média: %.2f dB\n', mean(SINR_dB_vetor));

% =========================================================================
% ITEM 8: Cálculo da taxa de transmiss˜ao
% =========================================================================
Taxa_Mbps_vetor = calcula_taxa(SINR_lin, B_Hz);

% PRINT
fprintf('ITEM 8: Cálculo da da taxa de transmiss˜ao\n');
fprintf('Taxa média: %.2f Mbps\n', mean(Taxa_Mbps_vetor));


% =========================================================================
% ITEM 9: Simulação em Larga Escala (Monte Carlo)
% =========================================================================
% Repete-se o cenário (Itens 2 a 8) para um número muito maior de
% realizações de usuários e de canal, de forma a obter estatísticas
% (CDFs) confiáveis para a SINR e para a taxa de transmissão.

N_MC = 20000; % Número de "drops" de usuários simulados (Monte Carlo)

% -------------------------------------------------------------------------
% 1. Geração vetorizada de N_MC usuários uniformes na célula central (BS0)
% -------------------------------------------------------------------------
% A área do hexágono corresponde a aproximadamente 90,7% da área do
% quadrado que o circunscreve. Geramos candidatos em lotes (em vez de um
% a um) para acelerar a rejeição, mantendo o mesmo método usado no Item 1.
MC_UE_x = zeros(1, N_MC);
MC_UE_y = zeros(1, N_MC);

cont_mc = 0;
while cont_mc < N_MC
    n_falta = N_MC - cont_mc;
    n_lote  = ceil(n_falta / 0.85); % margem de segurança sobre a razão de área

    px = (rand(1, n_lote) - 0.5) * 2 * R;
    py = (rand(1, n_lote) - 0.5) * 2 * R;

    dentro = inpolygon(px, py, hex_base_x, hex_base_y);
    px = px(dentro);
    py = py(dentro);

    n_aceitos = min(length(px), n_falta);
    MC_UE_x(cont_mc + 1 : cont_mc + n_aceitos) = px(1:n_aceitos);
    MC_UE_y(cont_mc + 1 : cont_mc + n_aceitos) = py(1:n_aceitos);
    cont_mc = cont_mc + n_aceitos;
end

% -------------------------------------------------------------------------
% 2. Perda de percurso para os N_MC usuários, contra as 7 BSs
% -------------------------------------------------------------------------
dist_MC_km = zeros(7, N_MC);
PL_MC_dB   = zeros(7, N_MC);

for b = 1:7
    dist_MC_km(b, :) = sqrt((MC_UE_x - BS_x(b)).^2 + (MC_UE_y - BS_y(b)).^2);
    PL_MC_dB(b, :)   = calcula_path_loss(dist_MC_km(b, :), d_0_km, PL_0_dB, n_PL);
end

% -------------------------------------------------------------------------
% 3. Sombreamento e desvanecimento rápido i.i.d. para cada realização
% -------------------------------------------------------------------------
sh_MC_dB    = gera_sombreamento(sigma_sh_dB, 7, N_MC);
h_MC_fading = gera_fast_fading(7, N_MC);

% -------------------------------------------------------------------------
% 4. Potência recebida, SINR e taxa de transmissão para os N_MC usuários
% -------------------------------------------------------------------------
P_rx_MC_linear = calcula_potencia_rx(P_tx_dBm, PL_MC_dB, sh_MC_dB, h_MC_fading);
[SINR_MC_lin, SINR_MC_dB] = calcula_sinr(P_rx_MC_linear, P_ruido, N_I);
Taxa_MC_Mbps = calcula_taxa(SINR_MC_lin, B_Hz);

fprintf('\n===================================================\n');
fprintf('ITEM 9: SIMULAÇÃO EM LARGA ESCALA (MONTE CARLO)\n');
fprintf('===================================================\n');
fprintf('Realizações simuladas (N_MC): %d usuários\n', N_MC);
fprintf('SINR média simulada  : %.2f dB\n', mean(SINR_MC_dB));
fprintf('Taxa média simulada  : %.2f Mbps\n', mean(Taxa_MC_Mbps));
fprintf('===================================================\n\n');


% =========================================================================
% ITEM 10: Geração das CDFs
% =========================================================================
% CDF empírica da SINR (dB) e da taxa de transmissão (Mbps), obtidas a
% partir de todos os N_MC usuários simulados no Item 9.

[x_SINR_cdf, F_SINR_cdf] = calcula_cdf_empirica(SINR_MC_dB);
[x_Taxa_cdf, F_Taxa_cdf] = calcula_cdf_empirica(Taxa_MC_Mbps);

figure;

subplot(1, 2, 1); hold on; grid on;
plot(x_SINR_cdf, F_SINR_cdf, 'LineWidth', 2, 'Color', [0 0.447 0.741]);
xlabel('SINR (dB)');
ylabel('CDF F(x)');
title('CDF Empírica da SINR');

subplot(1, 2, 2); hold on; grid on;
plot(x_Taxa_cdf, F_Taxa_cdf, 'LineWidth', 2, 'Color', [0.85 0.325 0.098]);
xlabel('Taxa de Transmissão (Mbps)');
ylabel('CDF F(x)');
title('CDF Empírica da Taxa de Transmissão');

sgtitle(sprintf('Item 10: CDFs Empíricas (N_{MC} = %d usuários)', N_MC));

fprintf('ITEM 10: GERAÇÃO DAS CDFs CONCLUÍDA\n');
fprintf('P(SINR <= 0 dB)         : %.2f%%\n', 100 * mean(SINR_MC_dB <= 0));
fprintf('Taxa mediana (50%%)      : %.2f Mbps\n', median(Taxa_MC_Mbps));
fprintf('===================================================\n\n');


% =========================================================================
% ITEM 11: Análise de Sensibilidade
% =========================================================================
% Repetimos a simulação de larga escala variando dois parâmetros do
% sistema (sigma_sh e N_I), mantendo os demais fixos e reaproveitando as
% mesmas posições de usuários (MC_UE_x, MC_UE_y) e, portanto, o mesmo
% Path Loss (PL_MC_dB) do Item 9. Isso isola o efeito de cada parâmetro
% sobre as CDFs, sem misturar variações de geometria.

% -------------------------------------------------------------------------
% Análise 1: Variação do desvio padrão do sombreamento (sigma_sh)
% -------------------------------------------------------------------------
vetor_sigma_sh = [4, 8, 12]; % dB (baixo, nominal da equipe, alto)
cores_sigma = {[0 0.447 0.741], [0.85 0.325 0.098], [0.466 0.674 0.188]};

figure; hold on; grid on;
for k = 1:length(vetor_sigma_sh)
    sigma_atual = vetor_sigma_sh(k);

    sh_temp  = gera_sombreamento(sigma_atual, 7, N_MC);
    h_temp   = gera_fast_fading(7, N_MC);
    Prx_temp = calcula_potencia_rx(P_tx_dBm, PL_MC_dB, sh_temp, h_temp);
    [~, SINR_temp_dB] = calcula_sinr(Prx_temp, P_ruido, N_I);

    [x_temp, F_temp] = calcula_cdf_empirica(SINR_temp_dB);
    plot(x_temp, F_temp, 'LineWidth', 2, 'Color', cores_sigma{k}, ...
        'DisplayName', sprintf('\\sigma_{sh} = %d dB', sigma_atual));
end
xlabel('SINR (dB)');
ylabel('CDF F(x)');
title('Item 11: Sensibilidade da CDF de SINR ao Sombreamento (\sigma_{sh})');
legend('Location', 'southeast');
hold off;

% -------------------------------------------------------------------------
% Análise 2: Variação do número de interferentes ativos (N_I)
% -------------------------------------------------------------------------
% Aqui reaproveitamos diretamente P_rx_MC_linear (Item 9), pois apenas a
% forma de somar a interferência muda, não a potência recebida em si.
vetor_N_I = [1, 2, 4, 6];
cores_NI = {[0 0.447 0.741], [0.85 0.325 0.098], [0.466 0.674 0.188], [0.494 0.184 0.556]};

figure; hold on; grid on;
for k = 1:length(vetor_N_I)
    NI_atual = vetor_N_I(k);

    [~, SINR_temp_dB] = calcula_sinr(P_rx_MC_linear, P_ruido, NI_atual);
    [x_temp, F_temp] = calcula_cdf_empirica(SINR_temp_dB);

    plot(x_temp, F_temp, 'LineWidth', 2, 'Color', cores_NI{k}, ...
        'DisplayName', sprintf('N_I = %d', NI_atual));
end
xlabel('SINR (dB)');
ylabel('CDF F(x)');
title('Item 11: Sensibilidade da CDF de SINR ao Número de Interferentes (N_I)');
legend('Location', 'southeast');
hold off;

fprintf('ITEM 11: ANÁLISE DE SENSIBILIDADE CONCLUÍDA\n');
fprintf('Parâmetros variados: sigma_sh (sombreamento) e N_I (interferentes)\n');
fprintf('Tendência esperada 1: sigma_sh maior -> CDF mais espalhada (maior\n');
fprintf('  variância da SINR), com cauda inferior mais pesada (mais usuários\n');
fprintf('  em outage), embora a média em dB pouco se altere.\n');
fprintf('Tendência esperada 2: N_I maior -> mais potência interferente somada\n');
fprintf('  -> CDF da SINR desloca-se para a esquerda (piora), reduzindo a\n');
fprintf('  taxa de transmissão de forma sistemática.\n');
fprintf('===================================================\n\n');


% =========================================================================
% ITEM 12 (QUESTÃO DESAFIO): Controle de Potência Fracionário
% =========================================================================
% Refaz a simulação completa de larga escala (Item 9) introduzindo um
% esquema de controle de potência fracionário (FPC), no qual a potência
% de transmissão de cada enlace compensa PARCIALMENTE a perda de percurso
% (ver calcula_controle_potencia.m). Reaproveitamos EXATAMENTE as mesmas
% posições de usuários (MC_UE_x, MC_UE_y), o mesmo Path Loss (PL_MC_dB) e
% as mesmas realizações de sombreamento (sh_MC_dB) e desvanecimento
% rápido (h_MC_fading) do Item 9, de forma a isolar unicamente o efeito
% do controle de potência (comparação "com" vs "sem" pareada/justa).

% -------------------------------------------------------------------------
% 1. Parâmetros do controle de potência fracionário
% -------------------------------------------------------------------------
P_max_dBm = P_tx_dBm;      % Potência máxima de transmissão (40 dBm, igual ao cenário original)
P_min_dBm = P_max_dBm - 20; % Potência mínima de transmissão (assumida: 20 dB de faixa dinâmica)
alpha_PC  = 0.6;            % Fator de compensação fracionário (0 = sem controle, 1 = compensação total)

% Perdas de percurso de referência que definem a faixa de normalização:
% PL_min_ref -> perda de percurso bem próximo da BS (distância d0)
% PL_max_ref -> perda de percurso na borda da célula (distância R)
PL_min_ref_dB = calcula_path_loss(d_0_km, d_0_km, PL_0_dB, n_PL);
PL_max_ref_dB = calcula_path_loss(R,      d_0_km, PL_0_dB, n_PL);

% -------------------------------------------------------------------------
% 2. Potência de transmissão controlada para cada enlace (7 BSs x N_MC)
% -------------------------------------------------------------------------
P_tx_PC_dB_MC = calcula_controle_potencia(PL_MC_dB, alpha_PC, P_max_dBm, P_min_dBm, ...
                                           PL_min_ref_dB, PL_max_ref_dB);

% -------------------------------------------------------------------------
% 3. Potência recebida, SINR e taxa de transmissão -- CENÁRIO COM CONTROLE
% -------------------------------------------------------------------------
P_rx_PC_MC_linear = calcula_potencia_rx(P_tx_PC_dB_MC, PL_MC_dB, sh_MC_dB, h_MC_fading);
[SINR_PC_MC_lin, SINR_PC_MC_dB] = calcula_sinr(P_rx_PC_MC_linear, P_ruido, N_I);
Taxa_PC_MC_Mbps = calcula_taxa(SINR_PC_MC_lin, B_Hz);

% -------------------------------------------------------------------------
% 4. CDFs empíricas: SEM controle (Item 9/10) vs. COM controle
% -------------------------------------------------------------------------
[x_SINR_PC_cdf, F_SINR_PC_cdf] = calcula_cdf_empirica(SINR_PC_MC_dB);
[x_Taxa_PC_cdf, F_Taxa_PC_cdf] = calcula_cdf_empirica(Taxa_PC_MC_Mbps);

figure;

subplot(1, 2, 1); hold on; grid on;
plot(x_SINR_cdf,    F_SINR_cdf,    'LineWidth', 2, 'Color', [0.6 0.6 0.6], 'DisplayName', 'Sem controle de potência');
plot(x_SINR_PC_cdf, F_SINR_PC_cdf, 'LineWidth', 2, 'Color', [0.85 0.325 0.098], 'DisplayName', sprintf('Com controle (\\alpha = %.1f)', alpha_PC));
xlabel('SINR (dB)');
ylabel('CDF F(x)');
title('CDF da SINR: Com vs. Sem Controle de Potência');
legend('Location', 'southeast');
hold off;

subplot(1, 2, 2); hold on; grid on;
plot(x_Taxa_cdf,    F_Taxa_cdf,    'LineWidth', 2, 'Color', [0.6 0.6 0.6], 'DisplayName', 'Sem controle de potência');
plot(x_Taxa_PC_cdf, F_Taxa_PC_cdf, 'LineWidth', 2, 'Color', [0 0.447 0.741], 'DisplayName', sprintf('Com controle (\\alpha = %.1f)', alpha_PC));
xlabel('Taxa de Transmissão (Mbps)');
ylabel('CDF F(x)');
title('CDF da Taxa: Com vs. Sem Controle de Potência');
legend('Location', 'southeast');
hold off;

sgtitle(sprintf('Item 12 (Desafio): Efeito do Controle de Potência Fracionário (\\alpha = %.1f, N_{MC} = %d)', alpha_PC, N_MC));

% -------------------------------------------------------------------------
% 5. Gráfico de apoio: potência de transmissão aplicada vs. distância
%    (evidencia visualmente a lógica do controle fracionário: usuários
%    próximos da BS transmitem menos, usuários de borda seguem em P_max)
% -------------------------------------------------------------------------
figure; hold on; grid on;
scatter(dist_MC_km(1, :), P_tx_PC_dB_MC(1, :), 6, [0.2 0.4 0.8], 'filled', 'MarkerFaceAlpha', 0.25);
yline(P_max_dBm, '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5, 'DisplayName', 'P_{max} (sem controle)');
xlabel('Distância à BS servidora (km)');
ylabel('Potência de Transmissão P_{tx} (dBm)');
title(sprintf('Item 12 (Desafio): Potência Aplicada pelo Controle Fracionário (\\alpha = %.1f)', alpha_PC));
legend('Enlaces BS0 \rightarrow Usuários simulados', 'Location', 'southeast');
hold off;

% -------------------------------------------------------------------------
% 6. Métricas quantitativas para responder às 3 perguntas do desafio
% -------------------------------------------------------------------------
% Usuários de "borda de célula": definidos aqui como os 10% mais distantes
% da própria BS servidora (BS0), i.e. distância >= percentil 90 dentre os
% usuários simulados no Item 9.
limiar_borda_km = prctile(dist_MC_km(1, :), 90);
mask_borda = dist_MC_km(1, :) >= limiar_borda_km;

SINR_media_sem  = mean(SINR_MC_dB);
SINR_media_com  = mean(SINR_PC_MC_dB);
SINR_borda_sem  = mean(SINR_MC_dB(mask_borda));
SINR_borda_com  = mean(SINR_PC_MC_dB(mask_borda));

% Nível de interferência percebido pelos demais usuários (soma da potência
% das N_I interferentes mais fortes, em escala linear -> média em dBm)
Interf_sem_linear = sum(P_rx_MC_linear(2:(N_I + 1), :), 1);
Interf_com_linear = sum(P_rx_PC_MC_linear(2:(N_I + 1), :), 1);
Interf_media_sem_dBm = 10 * log10(mean(Interf_sem_linear));
Interf_media_com_dBm = 10 * log10(mean(Interf_com_linear));

% Índice de justiça de Jain (Jain's Fairness Index) sobre a taxa de cada usuário
jain_index = @(x) (sum(x)).^2 / (numel(x) * sum(x.^2));
Jain_sem = jain_index(Taxa_MC_Mbps);
Jain_com = jain_index(Taxa_PC_MC_Mbps);

% Capacidade agregada do sistema (soma das taxas de todos os usuários
% simulados) - usada aqui como proxy comparativo de capacidade total
Cap_agregada_sem = sum(Taxa_MC_Mbps);
Cap_agregada_com = sum(Taxa_PC_MC_Mbps);

fprintf('\n===================================================\n');
fprintf('ITEM 12 (QUESTÃO DESAFIO): CONTROLE DE POTÊNCIA FRACIONÁRIO\n');
fprintf('===================================================\n');
fprintf('Parâmetros: alpha_PC = %.2f | P_max = %d dBm | P_min = %d dBm\n', alpha_PC, P_max_dBm, P_min_dBm);
fprintf('Usuários de borda considerados: %.0f%% mais distantes (d >= %.3f km)\n\n', 10, limiar_borda_km);

fprintf('--- (1) SINR média vs. SINR de borda ---\n');
fprintf('SINR média geral   : sem controle = %.2f dB | com controle = %.2f dB | Delta = %+.2f dB\n', ...
        SINR_media_sem, SINR_media_com, SINR_media_com - SINR_media_sem);
fprintf('SINR média (borda) : sem controle = %.2f dB | com controle = %.2f dB | Delta = %+.2f dB\n\n', ...
        SINR_borda_sem, SINR_borda_com, SINR_borda_com - SINR_borda_sem);

fprintf('--- (2) Nível de interferência percebido pelos demais usuários ---\n');
fprintf('Interferência média: sem controle = %.2f dBm | com controle = %.2f dBm | Delta = %+.2f dB\n\n', ...
        Interf_media_sem_dBm, Interf_media_com_dBm, Interf_media_com_dBm - Interf_media_sem_dBm);

fprintf('--- (3) Trade-off entre justiça (fairness) e capacidade agregada ---\n');
fprintf('Índice de Jain (taxa): sem controle = %.4f | com controle = %.4f | Delta = %+.4f\n', ...
        Jain_sem, Jain_com, Jain_com - Jain_sem);
fprintf('Capacidade agregada  : sem controle = %.1f Mbps | com controle = %.1f Mbps | Delta = %+.2f%%\n', ...
        Cap_agregada_sem, Cap_agregada_com, 100 * (Cap_agregada_com - Cap_agregada_sem) / Cap_agregada_sem);
fprintf('===================================================\n\n');