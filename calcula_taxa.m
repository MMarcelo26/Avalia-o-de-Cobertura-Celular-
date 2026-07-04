function Taxa_Mbps = calcula_taxa(SINR_linear, B_Hz)
% SINR_linear: Vetor de SINR na escala linear
% B_Hz: Largura de banda em Hz

% Cálculo da capacidade de Shannon
Taxa_bps = B_Hz * log2(1 + SINR_linear);

% Conversão para Mbps
Taxa_Mbps = Taxa_bps / 1e6;
end
