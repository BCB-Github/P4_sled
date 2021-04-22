%% Transferfunction analysis %%
clear
%%Variable Setup%%


J_1     = 194.3e-9 +275.4e-9 +2*5.1e-9 + 13e-6;             %Inertia of motor system+ first gear
J_2     = (2*1.65e-6 + 4*5.1e-9 + 24.09e-6 +229.9e-9+ 255.7e-9);        %Inertia of sled and attached gears
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


a = 0.01:0.01:0.5; %Variation of modification to start frequency
a_0 = 0.1:0.1:5;    %Variation of steady state error value
push = 0.1:0.1:5;   %Variation of lead start freq
T = 0:0.001:25;    %Time vector


stepAmp = 0.5; %Amplitude of step
opt = stepDataOptions('StepAmplitude',stepAmp)

%% Regulator Coeffecients %%

%Spørg Henrik hvis det ikke giver mening, gider ikke skrive alle mulige kommentare%

[G_pi1 G_pi2 G_pi3 G_pi4] = margin(G_ol);

for k=1:length(a_0)

for j=1:length(push)

    omega_pi(j) = G_pi4*push(j); %Change this to push the the lead response in relation to the crossover frequency


    parfor i=1:length(a)
        G_lead(k,j,i) = tf([1/omega_pi(j) a_0(k)], [a(i)/omega_pi(j) 1]);
    
        G_design_f(k,j,i) = G_lead(k,j,i) *G_ol;
        
        G_cont(k,j,i) = G_lead(k,j,i);
        
        Y = step(feedback(G_design_f(k,j,i), 1), T, opt);

        si(k,j,i) = stepinfo(Y, T);
end
end
end
