% J_1     = 194e-9 + 1.3e-5;          %Inertia of motor system+ first gear
% J_2     = 2.41e-5 + 2*1.5e-6;       %Inertia of sled and attached gears
% M_3     = 0.723 + 0.108;            %Mass of sled system
% B       = 3.4;          %Viscous friction 
% L_m     = 219e-6;       %Motor inductance
% R_m     = 0.66;         %Motor resistance
% K_tau   = 42e-3;        %Torque coeffecient 
% K_m     = 0.264;        %Back-EMF coeffecient
% n_1     = 1/3;          %First gearing constant
% r_3     = 0.01571;      %Radius of gear 3
% J = J_1 + n_1^2 *(J_2 + M_3*r_3^2);     % Total equivalent Inertia


J_1     = 194.3e-9 +275.4e-9 +2*5.1e-9 + 13e-6;

J_2     = (2*1.65e-6 + 4*5.1e-9 + 24.09e-6 +229.9e-9+ 255.7e-9);
M_3     = 0.546 + 0.14;            %Mass of sled system
B       = 3.4;                       %Viscous friction 
K_tau   = 42e-3;                    %Torque coeffecient 
n_1     = 1/3;                      %First gearing constant
r_3     = 0.0127;                  %Radius of gear 3

J_eq = J_1 + n_1^2 *(J_2 + M_3*r_3^2); %Equivalent inertia of the system, as seen from the motor

T_sample = 0.001;                   %Sample time of controller

Delta = 0.0000079;                  %Smallest distance the encoder measures
