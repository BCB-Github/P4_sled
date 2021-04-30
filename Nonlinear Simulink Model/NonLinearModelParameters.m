%% Modelling Parameters
T_sample = 0.001;           %Sample time of controller
step_size = 1;              %% magnitude of step response
disc_type = 0;              %% 0 is for Backwards Difference, 1 is for forwards_difference






%% Types of controller : values for sat_cont
%1 : PI LEAD 1
%2 : PI LEAD 2
%3 : LEAD no SAT 0.1M
%4 : LEAD SAT 0.1M
%5 : PID MED POL CONTROLLER
sat_cont = 2;               %% CHOICE OF CONTROLLER


%% SYSTEM PARAMETERS

J_1     = 194.3e-9 +275.4e-9 +2*5.1e-9 + 13e-6;
J_2     = (2*1.65e-6 + 4*5.1e-9 + 24.09e-6 +229.9e-9+ 255.7e-9);
M_3     = 0.546 + 0.14;                 %Mass of sled system
B       = 3.4;                          %Viscous friction
K_tau   = 42e-3;                        %Torque coeffecient
n_1     = 1/3;                          %First gearing constant
r_3     = 0.0127;                       %Radius of gear 3
J_eq = J_1 + n_1^2 *(J_2 + M_3*r_3^2);  %Equivalent inertia of the system, as seen from the motor
Delta = 0.0000079;                      %Smallest distance the encoder measures






%% Initialization of parameters
k_d = 0;
discrete_cont_lead = zeros(1, 4);

if sat_cont == 1 %% PI LEAD 1
    cont_num_master = [1.517, 3.296, 0.2386];
    cont_den_master = [0.0405206, 1, 0];
    
    
    cont_num_lead = [0.8104, 1.7];
    cont_den_lead = [0.04052, 1];
    
    
    %cont_num_master = cont_num_lead;
    %cont_den_master = cont_den_lead;
    
    
    k_i = 0.1404;
    k_p = 1.872;
    
elseif sat_cont == 2 %% PI LEAD 2
    cont_num_master  = [3.034, 7.826, 0.3837];
    cont_den_master = [0.01621, 1, 0];
    
    cont_num_lead = [1.621, 4.1];
    cont_den_lead = [0.01621, 1];
    
    k_i = 0.1404;
    k_p = 1.872;
elseif sat_cont == 3 %% nice lead controller - no sat 0.1 m
    
    
    cont_num_master = [1.604 3];
    cont_den_master = [0.04812 1];
    cont_num_lead = [1.604 3];
    cont_den_lead  = [0.04812 1];
    
    
elseif sat_cont == 4 %% nice lead controller - no sat 0.1 m
    
    
    cont_num_master = [2.406 5];
    cont_den_master = [0.02406 1];
    cont_num_lead = cont_num_master;
    cont_den_lead  = cont_den_master;
     
else
    % PID med pol
    %   1.517 s^2 + 3.296 s + 0.2386
    % ----------------------------
    %              s
    %      1
    %  -------------
    %   0.04052 s + 1
    
    cont_num_master = [1.517, 3.296, 0.2386];
    cont_den_master = [0.04052 1 0];
    cont_num_lead = [1.621, 4.1];
    cont_den_lead = [0.01621, 1];
    k_d = 1.517;
    k_p = 3.296;
    k_i = 0.2386;
    k_lead_pol = 0.04052;
    
    cont_num = [1];
    cont_den = [0.4052, 1];
    run('model_disc_controller_creator.m');
    discrete_cont_lead = discrete_constants;
    
    T_i = sqrt(k_d/k_i);
end





%% These are the controller constants for the anti-windup
cont_num = [0, 1];
cont_den = [1, 0];
run('model_disc_controller_creator.m');
cont_integrator_discrete = discrete_constants;


%% FOR EVT. DISCRETE DIFFERENTIATOR
%cont_num = [1, 0];
%cont_den = [1];
%run('model_disc_controller_creator.m');
%cont_differentiator_discrete = discrete_constants;

%% Controller §§§ CONTROLLER PARAMETERS GO HERE §§§§
%Nice lead controllere:
%3. No sat ved 0.1 m
%cont_num = [1.604 3];
%cont_den = [0.04812 1];
%4. Sat ved 1 m
%cont_num = [2.406 5];
%cont_den = [0.02406 1];
%Nice PI-Lead controlllere:
%1. Sat ved 0.1 m
%cont_num = [1.517, 3.296, 0.2386];
%cont_den = [0.0405206, 1, 0];
%2. Sat ved 0.1 m
%cont_num  = [3.034, 7.826, 0.3837];
%cont_den = [0.01621, 1, 0];



%% TO FIND THE LEAD PARAMETERS FOR THE ANTI WINDUP
cont_num = cont_num_lead;
cont_den = cont_den_lead;
T_t = (k_p/k_i)/10; %% TRACKING CONSTANT for anti-windup in lead controller

%% Lead Controller AW block parameters
k_lead_param = cont_num(2);
T_lead_param = cont_num(1)/k_lead_param;
alpha_lead_param = cont_den(1)/T_lead_param;
F_lead_param = -1/(alpha_lead_param*T_lead_param);
G_lead_param = 1;
H_lead_param = k_lead_param/alpha_lead_param*(1/T_lead_param-1/(alpha_lead_param*T_lead_param));
L_lead_param = k_lead_param/alpha_lead_param;
M_lead_param = 1/L_lead_param;


%PI-Lead Controller AW block paramters
if length(cont_num) == 3 && length(cont_den) == 3
    PID_lead_led = tf([1],[cont_den(1) 1]);
    D_PID_param = cont_num(1);
    P_PID_param = cont_num(2);
    I_PID_param = cont_num(3);
    T_i = sqrt(D_PID_param/I_PID_param);
    cont_num_temp = cont_num;
    cont_den_temp = cont_den;
    cont_num = [1];
    cont_den = [cont_den(1) 1];
    run('model_disc_controller_creator.m');
    cont_Leadterm_discrete = discrete_constants;
    cont_num = cont_num_temp;
    cont_den = cont_den_temp;
else
    % Nedstående er ren nonsen og skal ikke bruges. Det er bare så simulink
    % ikke bliver sur over udefinerede værdier.
    PID_lead_led = 0;
    D_PID_param = 0;
    P_PID_param = 0;
    I_PID_param = 0;
    T_i = 1;
    cont_num_temp = cont_num;
    cont_den_temp = cont_den;
    run('model_disc_controller_creator.m');
    cont_Leadterm_discrete = discrete_constants;
end

%% For linear controller in model

cont_num =   cont_num_master;
cont_den=   cont_den_master;


