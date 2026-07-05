function [x_ordenado, F] = calcula_cdf_empirica(dados)
    % Função para calcular a CDF empírica de um vetor de amostras
    % (estimador da função de distribuição acumulada por ordenação).
    % Parâmetros:
    % dados      - vetor de amostras (ex.: SINR em dB, taxa em Mbps)
    % Saídas:
    % x_ordenado - amostras ordenadas em ordem crescente (eixo x da CDF)
    % F          - probabilidade acumulada F(x) = P(X <= x), variando de
    %              1/N até 1

    x_ordenado = sort(dados(:))';
    N = length(x_ordenado);
    F = (1:N) / N;
end
