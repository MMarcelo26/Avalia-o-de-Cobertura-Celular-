% =========================================================================
% COMUNICAÇÕES MÓVEIS I - APII SIMULAÇÃO
% ITEM 5: ILUSTRAÇÃO DAS COMPONENTES DO CANAL
% Parâmetros da Equipe: Dígito Final 3 (n = 3.0, sigma_sh = 8 dB)
% =========================================================================

clear; clc; close all;

% --- Configuração da Semente Aleatória (Utilizando matrícula) ---
% rng(603573); 

% --- Parâmetros Fixos (Tabela 2) ---
P_tx = 40;          % Potência de transmissão da BS (dBm) 
PL_0 = 30;          % Perda de referência (dB) em d0 = 1m 
d0 = 1;             % Distância de referência (m) 

% --- Parâmetros Customizados - Dígito 3 (Tabela 3) ---
n = 3.0;            % Expoente de perda de percurso 
sigma_sh = 8;       % Desvio padrão do sombreamento (dB) 

% --- Vetor de Distância ---
% Gerando um percurso linear de 1 metro até 1000 metros (passos de 1m)
d = 1:1:1000;       
N_amostras = length(d);

%% 1. Componente: Perda de Percurso (Tendência Média)
PL = PL_0 + 10 * n * log10(d / d0); % Eq. (1) 
P_rx_avg = P_tx - PL;               % Potência média recebida (dBm)

%% 2. Componente: Sombreamento Log-Normal (Variação Lenta)
% Para que seja visualmente identificável como "lenta", aplica-se correlação espacial.
% Modelo de Gudmundson: rho = exp(-delta_d / d_cor)
delta_d = 1;        % Espaçamento entre amostras (1 metro)
d_cor = 50;         % Distância de correlação típica (50 metros) 
rho = exp(-delta_d / d_cor);

X_sigma = zeros(1, N_amostras);
X_sigma(1) = sigma_sh * randn(); % Primeira amostra 
for k = 2:N_amostras
    % Processo autoregressivo de ordem 1 (AR-1) para manter a variância estacional
    X_sigma(k) = rho * X_sigma(k-1) + sqrt(1 - rho^2) * sigma_sh * randn();
end

P_rx_large_scale = P_rx_avg - X_sigma; % Larga escala (Path Loss + Shadowing)

%% 3. Componente: Desvanecimento Rápido (Variação Rápida)
% Geração de ganho Rayleigh h (Eq. 4)
h_I = randn(1, N_amostras) / sqrt(2); 
h_Q = randn(1, N_amostras) / sqrt(2); 
h_sq = h_I.^2 + h_Q.^2;               % Potência instantânea |h|^2 
fast_fading_dB = 10 * log10(h_sq);

%% 4. Potência Recebida Total (Combinação das 3 camadas)
P_rx_total = P_rx_large_scale + fast_fading_dB; % Eq. (5) 

%% --- Plotagem do Gráfico Qualitativo ---
figure('Position', [100, 100, 850, 500]);

% Camada 3: Sinal Total (Cinza claro para destacar o fundo dinâmico)
plot(d, P_rx_total, 'Color', [0.75 0.75 0.75], 'LineWidth', 1, ...
    'DisplayName', 'Sinal Total (Path Loss + Sombreamento + Desvanecimento Rápido)');
hold on;

% Camada 2: Larga Escala (Azul para evidenciar as flutuações lentas)
plot(d, P_rx_large_scale, 'b-', 'LineWidth', 2, ...
    'DisplayName', 'Larga Escala (Path Loss + Sombreamento)');

% Camada 1: Tendência Média (Vermelho espesso mostrando a perda puramente geométrica)
plot(d, P_rx_avg, 'r-', 'LineWidth', 3, ...
    'DisplayName', 'Tendência Média (Apenas Path Loss)');

% Configurações estéticas do gráfico
grid on;
xlabel('Distância entre Transmissor e Receptor (m)', 'FontSize', 11);
ylabel('Potência Recebida (dBm)', 'FontSize', 11);
title(['Ilustração Qualitativa das Componentes do Canal (Matrícula Final 3: n = ', ...
    num2size(n), ', \sigma_{sh} = ', num2size(sigma_sh), ' dB)'], 'FontSize', 12);
legend('Location', 'southwest', 'FontSize', 10);
xlim([0 1000]);

% Função auxiliar interna para converter número em string no título
function s = num2size(val)
s = num2str(val, '%.1f');
end