% Configurações do controlador PI+D
kp = 10;
ti = 0.17;
td = 0.05;
alpha = 0.1;

% Configurações de ruídos
Np = 10^(-9);
Nm = 10^(-9);
Ts = 0.02;

% Configurações de Bias
Ubar = 0.5;
Ybar = 0.1;

% Configurações de atraso
Delay = 0.1;

% Configurações da planta
G_teste = tf([1], [1, 1]);
