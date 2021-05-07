
clear
%Simulation parameters go here
T_sample = 0.001;           %Sample time of controller
step_size_array = [1, 0.1];              %% magnitude of step response
disc_type = 0;              %% 0 is for Backwards Difference, 1 is for forwards_difference

%antiwindup  % either 'on' or 'off'
anti_windup = 'on';




%% Types of controller : values for sat_cont
%1 : PI LEAD 1 &&
%2 : PI LEAD 2
%3 : LEAD no SAT 0.1M
%4 : LEAD SAT 0.1M
%5 : PID MED POL CONTROLLER
%6 : PI LEAD 3 -  sat
%7 : PI LEAD 4  - no sat
sat_cont = 1;               %% CHOICE OF CONTROLLER


%% Choice of controllers to simulate - 0 means none of that type
CONT_PI_LEAD_ARRAY = [1, 2, 6, 7];
CONT_LEAD_ARRAY  = [3, 4];




%% Creates Empty Arrays for these tests
addpath('functions')
addpath('process_scripts')

run('NonLinearModelParameters.m')
run('initialize_values.m')
open_system("Discrete_Model.slx");




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
            sat_cont = CONT_PI_LEAD_ARRAY(i);
            run("NonLinearModelParameters");
            toc
            out = sim("Discrete_Model");
            
            PI_LEAD_ARRAY_RESULTS(:, i + (j-1) * length(CONT_PI_LEAD_ARRAY)) = out.last_test;
            toc
            
            %% Save values of the current run simulation
            PI_LEAD_ARRAY_old(i + (j-1) * length(CONT_PI_LEAD_ARRAY), :) = [T_sample, step_size_array(j), CONT_PI_LEAD_ARRAY(i)];
        end
end


%% VIRKER IKKE LIGE NU
% %%PID SIMULATION - antiwindup type 2
% assign_blocks('on1', 'PI-LEAD')
% for j = 1:length(step_size_array)
%     step_size = step_size_array(j);
%         for i = 1:length(CONT_PI_LEAD_ARRAY)
%             disp("Controller number " + CONT_PI_LEAD_ARRAY(i))
%             
%             %% if the simulation has run with the same parameters, then don't run it again
%             if isequal(PI_LEAD_ARRAY_old_1(i +(j-1)*length(CONT_PI_LEAD_ARRAY), :), [T_sample, step_size_array(j), CONT_PI_LEAD_ARRAY(i)])
%                 disp("This controller has already been simulated")
%                 continue
%             end
%             
%             %Timer
%             tic
%             sat_cont = CONT_PI_LEAD_ARRAY(i);
%             run("NonLinearModelParameters");
%             toc
%             out = sim("Discrete_Model");
%             
%             PI_LEAD_ARRAY_RESULTS_1(:, i + (j-1) * length(CONT_PI_LEAD_ARRAY)) = out.last_test;
%             toc
%             
%             %% Save values of the current run simulation
%             PI_LEAD_ARRAY_old_1(i + (j-1) * length(CONT_PI_LEAD_ARRAY), :) = [T_sample, step_size_array(j), CONT_PI_LEAD_ARRAY(i)];
%         end
% end


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
            toc
            out = sim("Discrete_Model");
            
            CONT_LEAD_ARRAY_RESULTS(:, i + (j-1) * length(CONT_LEAD_ARRAY)) = out.last_test;
            toc
            
            %% Save values of the current run simulation
            CONT_LEAD_ARRAY_OLD(i + (j-1) * length(CONT_LEAD_ARRAY), :) = [T_sample, step_size_array(j), CONT_LEAD_ARRAY(i)];

        end
end





disp("SIMULATION DONE");


%% for Plotting
time = 0:1/10000:3;

save_system



if CONT_PI_LEAD_ARRAY ~= 0
    plot(time, PI_LEAD_ARRAY_RESULTS)
    %plot(time, PI_LEAD_ARRAY_RESULTS_1)
end

if CONT_LEAD_ARRAY ~= 0
    plot (time, CONT_LEAD_ARRAY_RESULTS)
end

