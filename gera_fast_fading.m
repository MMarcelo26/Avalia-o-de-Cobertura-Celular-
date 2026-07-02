function h = gera_fast_fading(n_linhas, n_colunas)
    % Função para gerar coeficientes de desvanecimento rápido (Rayleigh)
    % A potência média do canal E[|h|^2] é unitária (1).
    % Parâmetros:
    % n_linhas  - Número de linhas (ex: antenas Tx)
    % n_colunas - Número de colunas (ex: antenas Rx ou subportadoras)
    
    % Gera um processo Gaussiano complexo com média 0 e variância 1
    % O fator 1/sqrt(2) garante que a variância total da potência seja 1
    real_part = randn(n_linhas, n_colunas);
    imag_part = randn(n_linhas, n_colunas);
    
    h = (1/sqrt(2)) * (real_part + 1i * imag_part);
end