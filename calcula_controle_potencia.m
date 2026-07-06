function P_tx_dB = calcula_controle_potencia(PL_dB, alpha_PC, P_max_dBm, P_min_dBm, PL_min_ref_dB, PL_max_ref_dB)
% =========================================================================
% QUESTÃO DESAFIO: Controle de Potência Fracionário (Fractional Power
% Control - FPC)
% =========================================================================
%
% Implementa um esquema de controle de potência no qual a potência de
% transmissão de cada enlace compensa PARCIALMENTE a perda de percurso
% (path loss) sofrida por aquele enlace, de forma análoga ao esquema de
% controle de potência fracionário usado no uplink do LTE (3GPP Open
% Loop Power Control).
%
% Ideia central:
%   - Enlaces com perda de percurso BAIXA (usuários próximos da BS
%     servidora) não precisam de potência máxima para obter uma boa
%     SINR, então o esquema REDUZ a potência transmitida para esses
%     enlaces.
%   - Enlaces com perda de percurso ALTA (usuários na borda da célula)
%     continuam operando próximos da potência máxima, pois precisam
%     dela para compensar a grande atenuação do canal.
%   - O parâmetro alpha_PC (fator de compensação) controla O QUANTO
%     dessa compensação é aplicado:
%       alpha_PC = 0   -> SEM controle de potência (todos os enlaces
%                         transmitem em P_max, reproduzindo exatamente
%                         o cenário original dos Itens 1-11)
%       alpha_PC = 1   -> compensação TOTAL (variação linear completa
%                         entre P_min e P_max ao longo de toda a faixa
%                         de perda de percurso da célula)
%       0 < alpha_PC < 1 -> compensação PARCIAL (fracionária)
%
% Parâmetros de entrada:
%   PL_dB          - Perda de percurso do(s) enlace(s) (dB). Pode ser
%                     escalar, vetor ou matriz (ex.: [7 x N_UE]).
%   alpha_PC       - Fator de compensação fracionário, entre 0 e 1.
%   P_max_dBm      - Potência máxima de transmissão da BS (dBm) - o
%                     mesmo P_tx_dBm usado no cenário sem controle.
%   P_min_dBm      - Potência mínima de transmissão da BS (dBm), usada
%                     para os enlaces mais próximos quando alpha_PC > 0.
%   PL_min_ref_dB  - Perda de percurso de referência mínima, avaliada
%                     em d0 (bem próximo da BS). Representa frac = 0.
%   PL_max_ref_dB  - Perda de percurso de referência máxima, avaliada
%                     no raio da célula R (borda). Representa frac = 1.
%
% Saída:
%   P_tx_dB        - Potência(s) de transmissão resultante(s) (dBm),
%                     com a mesma dimensão de PL_dB.
% =========================================================================

    % 1. Normaliza a perda de percurso de cada enlace dentro da faixa
    %    [PL_min_ref_dB, PL_max_ref_dB], mapeando para o intervalo [0, 1]:
    %    frac = 0 -> enlace bem próximo da BS (pouca perda de percurso)
    %    frac = 1 -> enlace na borda da célula (ou além dela)
    frac = (PL_dB - PL_min_ref_dB) / (PL_max_ref_dB - PL_min_ref_dB);
    frac = min(max(frac, 0), 1); % satura fora da faixa [0, 1]

    % 2. Aplica a compensação fracionária: quanto mais perto da BS
    %    (frac -> 0), maior a redução de potência aplicada (escalada
    %    por alpha_PC); na borda (frac -> 1), a potência permanece em
    %    P_max, pois (1 - frac) -> 0.
    P_tx_dB = P_max_dBm - alpha_PC * (1 - frac) * (P_max_dBm - P_min_dBm);
end
