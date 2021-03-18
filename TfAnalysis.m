%%% Transferfunction analysis %%%
clear
%%Variable Setup%%

J_1     = 194e-9 + 1.3e-5;          %Inertia of motor system+ first gear
J_2     = 2.41e-5 + 2*1.5e-6;       %Inertia of sled and attached gears
M_3     = 0.723 + 0.108;            %Mass of sled system
B       = 3.4                       %Viscous friction 
K_tau   = 42e-3;                    %Torque coeffecient 
n_1     = 1/3;                      %First gearing constant
r_3     = 0.01571;                  %Radius of gear 3

%% Equations %%

J = J_1 + n_1^2 *(J_2 + M_3*r_3^2); %Equivalent inertia of the system, as seen from the motor

G_1 = B*r_3;                        %Describes the first order terms in the mechanical transferfunction
G_2 = ((J/r_3) + r_3*M_3);          %Describes the second order terms in the mechanical transferfunction

num = [K_tau/n_1];           %Numerator polynomial of the mechanical transferfunction
den =[G_2 G_1 0];            %Denominator polynomial of the mechanical transferfunction

G_ol= tf([num], [den])      %Open loop transferfunction
G_cl = feedback(G_ol,1)     %Closed loop transferfunction with unity feedback


%% Analysis %%
%% Open Loop Analysis %%
close all

P_ol= pole(G_ol);       %Poles of the open loop system
Z_ol= zero(G_ol);       %Zeroes of the open loop system
damp(G_ol)              %Info on several key coeffecients are printed

% Several plots are created from the open loop transfer function

nyquist(G_ol)
figure;
nichols(G_ol)
figure;
margin(G_ol)

figure;
p = pzoptions;  %The following creates a root locus plot with a polar grid
p.Grid = 'on';
h = rlocusplot(G_ol, p);

%% Closed loop Analysis %%

Si=stepinfo(G_cl)       %Info on the response characteristics of the closed loop system are printed and saved
damp(G_cl)              %Info on several key coeffecients are printed for the closed loop system


%Figures relevant to the closed loop response are created
figure;
step(G_cl)
figure;
impulse(G_cl)


%% Ununsed TF of servomotor %%


%The following is unused but describes the transferfunction of a servomotor

% L_m     = 219e-6;       %Motor inductance
% R_m     = 0.66;         %Motor resistance
%K_m     = 0.264;        %Back-EMF coeffecient

% G_1 = r_3*n_1*n_2;              %Angular position to linear position
% G_2 = 1; %1/500;                    %Prototype gain controller

%Definition of numerator and denominator polynomials in the plant
%transferfunction

%num = [K_tau*G_1*G_2];  %Numerator polynomial 
%den = [(J*L_m) (B*L_m+J*R_m) (B*R_m+K_tau*K_m) 0];  %Denominator Polynomial  