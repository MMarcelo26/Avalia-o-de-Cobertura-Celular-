function sh_dB = gera_sombreamento(sigma_dB, n_linhas, n_colunas)
    % Função para gerar a matriz de sombreamento log-normal (Normal na escala dB)
    % Parâmetros:
    % sigma_dB  - Desvio padrão do sombreamento (dB)
    % n_linhas  - Número de linhas da matriz gerada (ex: qtde de BSs)
    % n_colunas - Número de colunas da matriz gerada (ex: qtde de usuários)
    
    % A função randn gera uma distribuição Normal de média 0 e variância 1.
    % Multiplicando por sigma_dB, ajustamos o desvio padrão para o valor desejado.
    sh_dB = sigma_dB * randn(n_linhas, n_colunas);
end