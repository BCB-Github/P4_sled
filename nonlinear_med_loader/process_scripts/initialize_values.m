if exist("PI_LEAD_ARRAY_old") == 0
    PI_LEAD_ARRAY_old = zeros(length(CONT_PI_LEAD_ARRAY) * length(step_size_array), 3)
end



if exist("PI_LEAD_ARRAY_old_1") == 0
    PI_LEAD_ARRAY_old_1 = zeros(length(CONT_PI_LEAD_ARRAY) * length(step_size_array), 3)
end
if exist("PI_LEAD_ARRAY_1m_1") == 0
    PI_LEAD_ARRAY_1m = zeros(3/T_sample*10 + 1, length(CONT_PI_LEAD_ARRAY)); %% 3 er simulation time
end





if exist("CONT_LEAD_ARRAY_OLD") == 0
    CONT_LEAD_ARRAY_OLD = zeros(length(CONT_LEAD_ARRAY) * length(step_size_array), 3)
end




%% INITIALIZES ARRAYS IF NECCESSARY
if exist("PI_LEAD_ARRAY_1m") == 0
    PI_LEAD_ARRAY_1m = zeros(3/T_sample*10 + 1, length(CONT_PI_LEAD_ARRAY)); %% 3 er simulation time
end

if exist("PI_LEAD_ARRAY_01m") == 0
    PI_LEAD_ARRAY_01m = zeros(3/T_sample*10 + 1, length(CONT_PI_LEAD_ARRAY)); %% 3 er simulation time
end

if exist("LEAD_ARRAY_1m") == 0
    LEAD_ARRAY_1m = zeros(3/T_sample*10 + 1, length(CONT_LEAD_ARRAY)); %% 3 er simulation time
end

if exist("LEAD_ARRAY_01m") == 0
    LEAD_ARRAY_01m = zeros(3/T_sample*10 + 1, length(CONT_LEAD_ARRAY)); %% 3 er simulation time
end




