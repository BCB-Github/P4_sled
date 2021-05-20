
model = 'Discrete_Model';
addpath('functions')
addpath('process_scripts')


simulation_time = 4;
time = 0:0.0001:simulation_time;

upper_bound = 1;
ranges = [-5, log10(upper_bound)];
n = 14; %% Simulation Depth
iter = 6; % antal zoomie bois





sat_cont = 1; %% not used for anything
run('nonlinear_quicktest.m')
%run('initialize_values.m') 
load_system(model);



assign_blocks('on', 'PI-LEAD')




%% initializing variable
best_time = 0;

%% This is the parameter to be adjusted
M_lead_param = 1/L_lead_param;



% This will be the inital base searching range
corrections_faktor =  logspace(log10(-5), log10(upper_bound), n);

%% maybe save for later
%T_t = (k_p/k_i)/10   %% TRACKING CONSTANT for anti-windup in PI-lead controller
%

% The number of iterations is iter:

%Changing Variable done here
controllers = [2, 6, 7];

loop_results = zeros(length(time), length(controllers));


step_size = 0.1

m_array = zeros(length(controllers), 2)

for k = 1:length(controllers)
sat_cont = controllers(k)
ranges = [-7, log10(upper_bound)];

corrections_faktor =  logspace(ranges(1), ranges(2), n);

for j = 1 :iter
    tic
    run('nonlinear_quicktest.m')
    step_size = 0.1;

    %% EVery iteration the logspace ranges change
    corrections_faktor =  logspace(ranges(1), ranges(2), n)
    for i = 1:n
        M_lead_param = corrections_faktor(i);
        
        %% If the simulation doesn't converge, fill a loop with zeros. - not ideal solution
        try
            out = sim(model,'StopTime',num2str(simulation_time));
            loop_results(:, i) =  out.last_test;

        catch 
 %                       out = sim(model,'StopTime',num2str(simulation_time));

            disp("Bounds extended")
            loop_results(:, i) = zeros(1, length(loop_results));
            continue
        end
        
        
       toc
    end
    
    tmp_best = 10;
    tmp_value_pass = 0;
    %tmp_best_2  = 3;
    
    for i = 1:n
        test_results(i) = stepinfo(loop_results(:, i), time, step_size);
    end
    
    i = 1;
    tmp_stepper = step_size;
    
    
    
    
    %% This whole while loop is cancer, but its here to make sure that if the step response is above one, a good value is still chosen
    % to continue with
    while i < (n + 1)
        %% break if the values don't diverge
        if tmp_stepper > 1.1
            break
            %% can't be solved, I guess
        end
        
        if test_results(i).SettlingTime < tmp_best && (test_results(i).SettlingMax < 1.05)
            tmp_best = test_results(i).SettlingTime;
            tmp_value_pass = i;
        end
        
        %% check if the pass didn't catch any values and extend the step_info parameters
        if (i == n) && (tmp_value_pass == 0)
            tmp_stepper = tmp_stepper + 0.015 * step_size;
            
            for ii = 1:n
                test_results(ii) = stepinfo(loop_results(:, ii), time, tmp_stepper);
                
                %% lidt indviklit, med det burde gerne catch de gode værdier
                if test_results(ii).SettlingTime < tmp_best && (test_results(i).SettlingMax < 1.05)
                    tmp_best = test_results(ii).SettlingTime;
                    tmp_value_pass = ii;
                end
            end
            if tmp_value_pass == 0
                i = 1;
            end
            
        end

        
        
        i = i + 1;
    end
    
    
    %% incase the step response doesn't tend to 1
    if 0 ==  tmp_value_pass
        ranges(1) = log10(corrections_faktor(n- 2))
        ranges(2) = log10(corrections_faktor(n))
        
    elseif tmp_value_pass <= 2
        ranges(1) = log10(corrections_faktor(tmp_value_pass))
        ranges(2) = log10(corrections_faktor(tmp_value_pass + 3))
        
    else
   
        
        ranges(1) = log10(corrections_faktor(tmp_value_pass - 2))
        ranges(2) = log10(corrections_faktor(tmp_value_pass + 1))
        
    end
    
    
    if ranges(1) > ranges(2)
        flip(ranges);
    end
    
    
      disp("Time taken for Iteration " + j + ":")

      toc
%     10^ranges(1)
%     10^ranges(2)
%     ranges
%     tmp_best
     figure()
     plot(time, loop_results)
     axis([0, 2, 0 , 2])
     saveas(gcf,"iteration" + controllers(k) + "_" + j)
     close(gcf); 
%     tmp_best
    
    
    %% make sure the program is still doing something
    %if abs(tmp_best_1 - tmp_best_2) > 0.0001
    %    disp("No differences between iteration detected")
    %    break
    %end
    
    
end

m_array(k, 1) = controllers(k)
m_array(k, 2) =     corrections_faktor(tmp_value_pass)
optimization_results(k) = stepinfo(loop_results(:, tmp_value_pass), time, step_size);
end

figure()
plot(time, loop_results)
axis([0, 2, 0 , 2])
10^ranges(1)


save optimization.mat



