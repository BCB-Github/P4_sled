%% PID %%

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


%% Regulator Coeffecients %%

s_1 = -5.33+5.595*j;
%s_1 =-5.33+5.33*j;


resp = evalfr(G_ol, s_1)

psi = angle(resp)
beta = angle(s_1);
gain = abs(resp);
w_n = abs(s_1);

a_0 = 1.7:0.0001:1.8;
b_0 = 2;

for i=1:length(a_0)

a_1(i) = (sin(beta)-a_0(i)*gain*sin(beta-psi))/(w_n*gain*sin(psi));

b_1(i) = (sin(beta+psi)+ a_0(i)*gain*sin(beta))/(-w_n * sin(psi));

G_cont(i) = tf([a_1(i) a_0(i)], [b_1(i) 1]);

G_design(i) = G_ol * G_cont(i);

si(i) = stepinfo(feedback(G_design(i), b_0));

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