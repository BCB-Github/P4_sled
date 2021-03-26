function out =  testing_function(u)
gamma = 749;
F_s = 17.5;
F_v = 13.0;
delta = 0.652; 


out = tanh(gamma * u(1) * (F_s + F_v * abs(u(1))^delta));

end 