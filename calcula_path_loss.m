function PL_dB = calcula_path_loss(d_km, d_0_km, PL_0_dB, n_PL)
    % Função para calcular a Perda de Percurso (Path Loss) log-distância
    % Parâmetros:
    % d_km    - Distância entre transmissor e receptor (km)
    % d_0_km  - Distância de referência (km)
    % PL_0_dB - Perda de percurso na distância de referência (dB)
    % n_PL    - Expoente de perda de percurso
    
    % Proteção: garante que a distância mínima seja d_0 para evitar logaritmo negativo ou de zero
    d_km = max(d_km, d_0_km);
    
    % Cálculo do Path Loss (Equação Log-Distância)
    PL_dB = PL_0_dB + 10 * n_PL * log10(d_km ./ d_0_km);
end