function assign_blocks(anti_windup,controller_type)
%ASSIGN_BLOCKS' Summary of this function goes here
%   Detailed explanation goes here

if strcmp(anti_windup, 'on') == 1

    if strcmp(controller_type, 'PI-LEAD') == 1
        set_param('Discrete_Model/Switch between Bens discrete PI-Lead AW and the rest','sw','1')
    end
    
    if strcmp(controller_type, 'LEAD') == 1
        set_param('Discrete_Model/Switch between Bens discrete PI-Lead AW and the rest','sw','0')
        set_param('Discrete_Model/Switch between No AW And AW','sw','0')
        set_param('Discrete_Model/Switch between lead and PID with AW','sw','1')
    end
    
    
elseif strcmp(anti_windup, 'on1') == 1
        if strcmp(controller_type, 'PI-LEAD') == 1
            set_param('Discrete_Model/Switch between Bens discrete PI-Lead AW and the rest','sw','0')
            set_param('Discrete_Model/Switch between No AW And AW','sw','0')
            set_param('Discrete_Model/Switch between lead and PID with AW','sw','0')
        end
    
elseif strcmp(anti_windup,'off') == 1
    
else 
    disp("ERROR: USE EITHER YES OR NO AS ANTI_WINDUP CRITERIA")
    return 
end

end

