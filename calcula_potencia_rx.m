function P_rx_linear = calcula_potencia_rx(P_tx_dBm, PL_dB, sh_dB, h_fast)
    % 1. Perda total de larga escala
    L_total_dB = PL_dB + sh_dB;
    
    % 2. Potência recebida em dBm
    P_rx_dBm = P_tx_dBm - L_total_dB + 10 * log10(abs(h_fast).^2);
    
    % 3. Converter para escala linear (mW)
    P_rx_linear = 10.^(P_rx_dBm / 10);
end