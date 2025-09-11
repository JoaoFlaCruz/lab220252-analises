%--------------------------------------------------------------------------
% Relatório Técnico: Projeto de Filtro Digital Passa-Baixas
% Script em MATLAB para filtrar dados de sinal ruidoso.
% Autor: Especialista em Sistemas de Controle Digital
% Data: 26 de Outubro de 2023
%--------------------------------------------------------------------------

%% 1. Inicialização e Definição de Parâmetros
%clear; close all; clc;

% Constantes do sistema fornecidas pelo usuário
Tau = 7.7779;
zeta = 1.5;

% Frequência natural do sistema (omega_n) em rad/s.
% Calculada a partir do novo Tau fornecido.
omega_n = 1 / Tau; 

% Frequência de corte do filtro (omega_b) em rad/s.
% Adota-se omega_b = omega_n/10 para não interferir na dinâmica da planta.
omega_b = omega_n / 10; 

% Tempo de amostragem (T_s) do experimento, em segundos.
Ts = 0.5; 

% Parâmetro de discretização 'k' para a transformada bilinear.
k = omega_b * Ts / 2;

% Declaração da função de transferência do filtro passa-baixas
% Usando a forma G(s) = 1 / ( (s/wb)^2 + sqrt(2)*(s/wb) + 1 )
% O denominador do filtro é H(s) = 1 / ( (s^2/wb^2) + sqrt(2)*(s/wb) + 1 )
% Que é equivalente a H(s) = wb^2 / (s^2 + sqrt(2)*wb*s + wb^2)
numerator = omega_b^2;
denominator = [1, sqrt(2)*omega_b, omega_b^2];
H_s = tf(numerator, denominator);
fprintf('Função de Transferência do Filtro Passa-Baixas (em tempo contínuo):\n');
disp(H_s);

%% 2. Carga e Preparação dos Dados
% Carrega os dados do arquivo 'cassio.txt'.
% A função readtable é utilizada para ler o arquivo de forma estruturada.
try
    dados = readtable('./cassio_dinamico2.txt', 'Delimiter', ' ', 'DecimalSeparator', ',');
catch
    error('O arquivo cassio.txt não foi encontrado. Verifique o caminho.');
end

% Converte a tabela para vetores numéricos para facilitar o processamento.
sinal_bruto = dados.Leitura;
sinal_escrita = dados.Escrita;
tempo_inicio_ciclo = dados.CicloInicio;

% Identifica o segmento de interesse (uma subida e uma descida de degrau) de forma dinâmica.
% A subida é encontrada onde o sinal de escrita muda de 5 para 6.
% A descida é encontrada onde o sinal de escrita muda de 6 para 5.
diff_escrita = diff(sinal_escrita);
indice_subida = find(diff_escrita > 0.5, 1, 'first') + 1;
indice_descida = find(diff_escrita < -0.5, 1, 'first') + 1;

% Isola o segmento de dados relevante.
sinal_bruto_seg = sinal_bruto(indice_subida:indice_descida);
sinal_escrita_seg = sinal_escrita(indice_subida:indice_descida);
tempo_seg = tempo_inicio_ciclo(indice_subida:indice_descida);

% A normalização do tempo é essencial para uma visualização clara.
tempo_seg_norm = (tempo_seg - tempo_seg(1)) / 1000000000; % Convertendo ns para s

%% 3. Aplicação do Filtro Digital Butterworth
% Inicializa o vetor para o sinal filtrado.
sinal_filtrado = zeros(size(sinal_bruto_seg));

% Inicializa os estados de memória para a equação de diferenças.
y_passado1 = 0; % y[n-1]
y_passado2 = 0; % y[n-2]
x_passado1 = 0; % x[n-1]
x_passado2 = 0; % x[n-2]

% Coeficientes do filtro discretizado.
a0 = 1 + sqrt(2)*k + k^2;
b0 = k^2 / a0;
b1 = 2*k^2 / a0;
b2 = k^2 / a0;
a1 = (2*k^2 - 2) / a0;
a2 = (1 - sqrt(2)*k + k^2) / a0;

% Aplica a equação de diferenças ponto a ponto.
for n = 1:length(sinal_bruto_seg)
    x_atual = sinal_bruto_seg(n);
    
    % Equação de diferenças do filtro Butterworth.
    sinal_filtrado(n) = b0*x_atual + b1*x_passado1 + b2*x_passado2 - a1*y_passado1 - a2*y_passado2;
    
    % Atualiza os estados de memória.
    x_passado2 = x_passado1;
    x_passado1 = x_atual;
    y_passado2 = y_passado1;
    y_passado1 = sinal_filtrado(n);
end

%% 4. Visualização dos Resultados
figure;
hold on;
grid on;
plot(tempo_seg_norm, sinal_bruto_seg, 'b', 'LineWidth', 1.0, 'DisplayName', 'Sinal Bruto (com Ruído)');
plot(tempo_seg_norm, sinal_filtrado, 'r', 'LineWidth', 2.0, 'DisplayName', 'Sinal Filtrado');
title('Comparação entre Sinal Bruto e Sinal Filtrado');
xlabel('Tempo (s)');
ylabel('Tensão (V)');
legend('show');
hold off;

%% 5. Visualização do modelo dinâmico e do filtro

fprintf('Função de Transferência do Filtro Passa-Baixas (em tempo contínuo):\n');
disp(H_s);

%% 6 . Visualiza a função de transferência do filtro em tempo discreto
H_z = c2d(H_s, Ts, 'zoh');
fprintf('Função de Transferência do Filtro Passa-Baixas (em tempo discreto):\n');
disp(H_z);