%%% Transferfunction analysis %%%
clear
%%Variable Setup%%

%J_1     = 194e-9 + 0.15e-7;        %Inertia of motor system
J_1     = 194e-9 + 0.13e-7;        %Inertia of motor system
J_2     = 24.1e-6 + 2*1.5e-6;        %Inertia of sled system
M_3     = 0.723 + 0.108;        %Mass of sled system
%B       = 3.18e-7;             %Viscous friction
B       = 4.966e-6;          
%L_m     = 85e-6;        %Motor inductance 
L_m     = 219e-6;
%R_m     = 5.45;        %Motor resistance
R_m     = 0.66;
%K_tau   = 2.68e-3;        %Motor torque coeffecient
K_tau   =42e-3;
%K_m     = 2.586e-2;        %Motor current constant
K_m     =42.02e-3;
n_1     = 1/3;      %First gearing constant
n_2     = 30/16;    %Second gearing constant
r_3     = 0.01571;     %Radius of gear 3

%% Equations %%
G_1 = r_3*n_1*n_2;
G_2 = 1/500;
J = J_1 + n_1^2 *(J_2 + M_3*r_3^2);

num = [K_tau*G_1*G_2];
den = [(J*L_m) (B*L_m+J*R_m) (B*R_m+K_tau*K_m) 0];

G_start= tf([num], [den])

G = feedback(G_start,1)

%% Analysis %%
close all

P= pole(G);
Z= zero(G);
Si=stepinfo(G)
step(G)
figure;
impulse(G)
figure;
bode(G)
figure;
nyquist(G)
figure;
nichols(G)
figure;
margin(G)
damp(G)
figure;
pzmap(G)
figure;
%rlocus(G)
p = pzoptions;
p.Grid = 'on';
h = rlocusplot(G, p);