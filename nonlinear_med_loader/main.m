

%Simulation parameters go here
T_sample = 0.001;           %Sample time of controller
step_size_array = [1, 0.1];              %% magnitude of step response
disc_type = 0;              %% 0 is for Backwards Difference, 1 is for forwards_difference

%antiwindup  % either 'on' or 'off'
anti_windup = 'on1';





%% Types of controller : values for sat_cont
%1 : PI LEAD 1 &&
%2 : PI LEAD 2
%3 : LEAD no SAT 0.1M
%4 : LEAD SAT 0.1M
%5 : PID MED POL CONTROLLER
%6 : PI LEAD 3 -  sat
%7 : PI LEAD 4  - no sat
sat_cont = 1;           %% CHOICE OF CONTROLLER


%% Choice of controllers to simulate - 0 means none of that type
CONT_PI_LEAD_ARRAY = [6, 7];
CONT_LEAD_ARRAY  = [0];






%% Creates Empty Arrays for these tests
addpath('functions')
addpath('process_scripts')

run('NonLinearModelParameters.m')
run('initialize_values.m')

%% Run linear simulation because, fine
open_system('linear_model.slx');
for i = 1:length(CONT_PI_LEAD_ARRAY) + length(CONT_LEAD_ARRAY)
    step_size = step_size_array(1);
    if i <= length(CONT_PI_LEAD_ARRAY)
        sat_cont = CONT_PI_LEAD_ARRAY(i);
        linear_array(i) = CONT_PI_LEAD_ARRAY(i);
    else
        sat_cont = CONT_LEAD_ARRAY(i - length(CONT_PI_LEAD_ARRAY));
        linear_array(i) = CONT_LEAD_ARRAY(i - length(CONT_PI_LEAD_ARRAY));
        
    end
    
    run("NonLinearModelParameters");
    out = sim('linear_model.slx');
    linear_results(i, :) = out.linear.Data;
    
    
    
end
linear_results = [0:0.0001:5; linear_results];

plot(linear_results(1, :), linear_results(2:(length(CONT_PI_LEAD_ARRAY) + length(CONT_LEAD_ARRAY)), :))
legend(strsplit(num2str(linear_array)))


%open_system();
load_system("Discrete_Model.slx");








%% This simulation is to create an array with the different PI-LEAD controllers using same parameters

disp("This is the PI - LEAD Simulation")
%%PID SIMULATION
assign_blocks('on', 'PI-LEAD')

for j = 1:length(step_size_array)
    step_size = step_size_array(j);
    for i = 1:length(CONT_PI_LEAD_ARRAY)
        disp("Controller number " + CONT_PI_LEAD_ARRAY(i))
        
        %% if the simulation has run with the same parameters, then don't run it again
        if isequal(PI_LEAD_ARRAY_old(i +(j-1)*length(CONT_PI_LEAD_ARRAY), :), [T_sample, step_size_array(j), CONT_PI_LEAD_ARRAY(i)])
            disp("This controller has already been simulated")
            continue
        end
        
        %Timer
        tic;
        sat_cont = CONT_PI_LEAD_ARRAY(i)
        run("NonLinearModelParameters");
        
        out = sim("Discrete_Model");
        
        PI_LEAD_ARRAY_RESULTS(:, i + (j-1) * length(CONT_PI_LEAD_ARRAY)) = out.last_test;
        toc
        
        %% Save values of the current run simulation
        PI_LEAD_ARRAY_old(i + (j-1) * length(CONT_PI_LEAD_ARRAY), :) = [T_sample, step_size_array(j), CONT_PI_LEAD_ARRAY(i)];
    end
end


% VIRKER IKKE LIGE NU
%%PID SIMULATION - antiwindup type 2
assign_blocks('on1', 'PI-LEAD')
for j = 1:length(step_size_array)
    step_size = step_size_array(j);
    for i = 1:length(CONT_PI_LEAD_ARRAY)
        
        if (CONT_PI_LEAD_ARRAY(i) == 1) || (CONT_PI_LEAD_ARRAY(i) == 2)
            continue
        end
        
        disp("Controller number " + CONT_PI_LEAD_ARRAY(i))
        
        %% if the simulation has run with the same parameters, then don't run it again
        if isequal(PI_LEAD_ARRAY_old_1(i +(j-1)*length(CONT_PI_LEAD_ARRAY), :), [T_sample, step_size_array(j), CONT_PI_LEAD_ARRAY(i)])
            disp("This controller has already been simulated")
            continue
        end
        
        %Timer
        tic
        sat_cont = CONT_PI_LEAD_ARRAY(i);
        run("NonLinearModelParameters");
        toc
        out = sim("Discrete_Model");
        
        PI_LEAD_ARRAY_RESULTS_1(:, i + (j-1) * length(CONT_PI_LEAD_ARRAY)) = out.last_test;
        toc
        
        %% Save values of the current run simulation
        PI_LEAD_ARRAY_old_1(i + (j-1) * length(CONT_PI_LEAD_ARRAY), :) = [T_sample, step_size_array(j), CONT_PI_LEAD_ARRAY(i)];
    end
end


disp("This is the LEAD Simulation")

%% for LEAD
assign_blocks(anti_windup, 'LEAD')
for j = 1:length(step_size_array)
    if CONT_LEAD_ARRAY(1) == 0
        break
    end
    step_size = step_size_array(j);
    for i = 1:length(CONT_LEAD_ARRAY)
        disp("Controller number " + CONT_LEAD_ARRAY(i))
        
        %% if the simulation has run with the same parameters, then don't run it again
        if isequal(CONT_LEAD_ARRAY_OLD(i +(j-1)*length(CONT_LEAD_ARRAY), :), [T_sample, step_size_array(j), CONT_LEAD_ARRAY(i)])
            disp("This controller has already been simulated")
            continue
        end
        
        %Timer
        tic;
        sat_cont = CONT_LEAD_ARRAY(i);
        run("NonLinearModelParameters");
        
        out = sim("Discrete_Model");
        
        CONT_LEAD_ARRAY_RESULTS(:, i + (j-1) * length(CONT_LEAD_ARRAY)) = out.last_test;
        toc
        
        %% Save values of the current run simulation
        CONT_LEAD_ARRAY_OLD(i + (j-1) * length(CONT_LEAD_ARRAY), :) = [T_sample, step_size_array(j), CONT_LEAD_ARRAY(i)];
        
    end
end





disp("SIMULATION DONE");


%% for Plotting
time = 0:1/10000:4;

save_system

for i  = 1:length(CONT_PI_LEAD_ARRAY) * length(step_size_array)
    %disp("Results of controller" + CONT_PI_LEAD_ARRAY(i));
    
    if i > length(CONT_PI_LEAD_ARRAY)
        PI_results(i) =  stepinfo(PI_LEAD_ARRAY_RESULTS(:, i), time, 0.1);
        
    else
        PI_results(i) =  stepinfo(PI_LEAD_ARRAY_RESULTS(:, i), time, 1);
    end
    
    
end


tmp = 0;
for i = 1:width(PI_LEAD_ARRAY_RESULTS_1)
    if PI_LEAD_ARRAY_RESULTS_1(200, i) == 0
        continue
    end
    tmp = tmp + 1;
    if tmp > (width(PI_LEAD_ARRAY_RESULTS_1)/4)
        PI_results_1(tmp) = stepinfo(PI_LEAD_ARRAY_RESULTS_1(:, i), time, 0.1);
        
    else
        PI_results_1(tmp) = stepinfo(PI_LEAD_ARRAY_RESULTS_1(:, i), time, 1);
    end
end











for i  = 1:length(CONT_LEAD_ARRAY) * length(step_size_array)
    %disp("Results of controller" + CONT_LEAD_ARRAY(i))
    
    if i > length(CONT_LEAD_ARRAY)
        LEAD_results(i) = stepinfo(CONT_LEAD_ARRAY_RESULTS(:, i), time, 0.1);
    else
        
        LEAD_results(i) = stepinfo(CONT_LEAD_ARRAY_RESULTS(:, i), time, 1);
    end
    
end





if CONT_PI_LEAD_ARRAY ~= 0
    
    plot(time, PI_LEAD_ARRAY_RESULTS)
    figure()
    %plot(time, PI_LEAD_ARRAY_RESULTS_1)
end

if CONT_LEAD_ARRAY ~= 0
    plot (time, CONT_LEAD_ARRAY_RESULTS)
end






