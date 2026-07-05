% =========================================================================
% APII - Simulação de Comunicações Móveis I
% Equipe 03 | Matrícula Responsável: 603573
% MATHEUS MARCELO COSTA DE SOUZA | DIOGO DE OLIVEIRA SOARES 
% ERIK RAY BARBOSA FALCÃO | ÍCARO RAY BARBOSA FALCÃO
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
