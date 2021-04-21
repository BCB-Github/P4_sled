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

J = J_1 + n_1^2 *(J_2 + M_3*r_3^2); %Equivalent inertia of the system, as seen from the motor

G_1 = B*r_3*n_1;                        %Describes the first order terms in the mechanical transferfunction
G_2 = (J/(r_3*n_1));          %Describes the second order terms in the mechanical transferfunction

num = [K_tau];           %Numerator polynomial of the mechanical transferfunction
den =[G_2 G_1 0];            %Denominator polynomial of the mechanical transferfunction

G_ol= tf([num], [den])      %Open loop transferfunction
G_cl = feedback(G_ol,1)     %Closed loop transferfunction with unity feedback


a = 0.01:0.01:0.5; %Variation of modification to start frequency
off = 0.01:0.01:0.1;    %Variation of PI start freq
push = 0.3:0.01:0.7;   %Variation of lead start freq
T = 0:0.001:25;

%[G_ol1 G_ol2 G_ol3 G_ol4] = margin(G_ol);

Y_out = zeros (length(off), length(push), length(a), length(T));
%w1 = G_ol4;

w1 = 2.5;      %Frequency where the phase (-180 + phase margin + 5) deg

gain = evalfr(G_ol, w1);

k_p = 1/gain;

for k = 1:length(off)

%off = 0.05; %Change this to push the lag response

k_i = off(k) * w1 * k_p;

G_pi(k) = tf([k_p k_i], [1 0]);

G_design(k) = G_ol * G_pi(k);

[G_pi1 G_pi2 G_pi3 G_pi4(k)] = margin(G_design(k));

for j=1:length(push)

    omega_pi(k,j) = G_pi4(k)*push(j); %Change this to push the the lead response in relation to the crossover frequency


    parfor i=1:length(a)
        G_lead(k,j,i) = tf([1/omega_pi(k,j) 1], [a(i)/omega_pi(k,j) 1]);
    
        G_lead_d(k,j,i) = G_lead(k,j,i) *G_design(k);
        
        G_cont(k,j,i) = G_lead(k,j,i) * G_pi(k);
        
        Y = step(feedback(G_lead_d(k,j,i), 1), T);
        
        Y_out(k,j,i,:) = Y(:);

        %si(k,j,i) = stepinfo(feedback(G_lead_d(k,j,i), 1));
        si(k,j,i) = stepinfo(Y, T);
end

end

end

% 
% Kp = cos(theta)/gain
% 
% Kd = sin(theta)/(w1*gain)
% 
% Ki = off*w1*Kp
% 
% s(1) = (-Kd+sqrt(Kp^2 -4*Kd*Ki))/2*Kd;
% s(2) = (-Kd-sqrt(Kp^2 -4*Kd*Ki))/2*Kd
% 
% wp = max(s)*10