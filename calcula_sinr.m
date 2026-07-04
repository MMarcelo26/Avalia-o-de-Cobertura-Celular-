function [SINR_linear, SINR_dB] = calcula_sinr(P_rx_total_linear, P_ruido_linear, N_I)
% Essa função tem como objetivo o cálculo da SINR, tendo em vista as 
% potências recebidas e o ruído.
% N_I: Número de interferentes ativos

% A primeira linha é a BS0 (servidora)
P_sinal = P_rx_total_linear(1, :);

% As demais são interferentes (BS1 a BS6)
% Somamos apenas as N_I primeiras interferentes
soma_interferencia = sum(P_rx_total_linear(2:(N_I + 1), :), 1);

% Cálculo da SINR
SINR_linear = P_sinal ./ (soma_interferencia + P_ruido_linear);
SINR_dB = 10 * log10(SINR_linear);
end