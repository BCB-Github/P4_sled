%% Transferfunction analysis %%
clear
%%Variable Setup%%

J_1     = 194.3e-9 + 13e-6 + 275.4e-6 + 2*5.1e-9;                 %Inertia of motor system+ first gear
J_1     = 194.3e-9 +275.4e-9 +2*5.1e-9 + 13e-6;
J_2     = 24.1e-6 + 2*1.65e-6 + 4*5.1e-9 + 229.9e-9 + 255.7e-9;   %Inertia of sled and attached gears
J_2     = (2*1.65e-6 + 4*5.1e-9 + 24.09e-6 +229.9e-9+ 255.7e-9);
M_3     = 0.546 + 0.14;            %Mass of sled system
B       = 3.4;                       %Viscous friction
K_tau   = 42e-3;                    %Torque coeffecient
n_1     = 1/3;                      %First gearing constant
r_3     = 0.0127;                  %Radius of gear 3

%% Equations %%

J = J_1 + n_1^2 *(J_2 + M_3*r_3^2);     %Equivalent inertia of the system, as seen from the motor

G_1 = B*r_3*n_1;                        %Describes the first order terms in the mechanical transferfunction
G_2 = (J/(r_3*n_1));                    %Describes the second order terms in the mechanical transferfunction

num = [K_tau];                          %Numerator polynomial of the mechanical transferfunction
den =[G_2 G_1 0];                       %Denominator polynomial of the mechanical transferfunction

G_ol= tf([num], [den])                  %Open loop transferfunction
G_cl = feedback(G_ol,1)                 %Closed loop transferfunction with unity feedback



%% Regulator Coeffecients %%

%Spørg Henrik hvis det ikke giver mening, gider ikke skrive alle mulige kommentare%

s_1 = -5.33+5.595*j;
%s_1 =-5.33+5.33*j;


resp = evalfr(G_ol, s_1)

psi = angle(resp)
beta = angle(s_1);
gain = abs(resp);
w_n = abs(s_1);

a_0 = 0.1:0.01:2;
%a_0 = [sqrt(2) sqrt(3) sqrt(pi)]
%b_0 = 0.1:0.1:2;
b_0 = 1


for i=1:length(a_0)
    
    for j = 1:length(b_0)
        
        a_1(i,j) = (sin(beta)-a_0(i)*gain*sin(beta-psi))/(w_n*gain*sin(psi));
        
        b_1(i,j) = (sin(beta+psi)+ a_0(i)*gain*sin(beta))/(-w_n * sin(psi));
        
        G_cont(i,j) = tf([a_1(i) a_0(i)], [b_1(i) b_0(j)]);
        
        G_design(i,j) = G_ol * G_cont(i,j);
        
        si(i,j) = stepinfo(feedback(G_design(i,j), 1));
        
    end
    
end





% G = 0.126/(0.01554*s_1^2 + 0.05341 * s_1)

% gain = abs(G)
% phi = angle(G)
%
% a_1 = (sin(beta)+gain*sin(beta-phi))/(abs(s_1)*sin(phi)*gain)
%
% b_1 =(sin(beta+phi) + gain * sin(beta))/(-abs(s_1)*gain)

%[2.2899 1]
%[0.4369 1]
