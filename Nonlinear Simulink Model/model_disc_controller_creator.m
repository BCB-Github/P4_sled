%The Idea is that this program will be able to process a transfer function and give an output as a function of discrete time steps

syms s
%%  USER SET VARIABLES  %%
%%TRANSFER FUNCTION THAT WILL BE CONVERTED
%C_s = 1/(s^3 + 2*s^2 + 2*s + 1);
%T = 0.001

%syms T % [s] Sampling time
T = T_sample;
%if exist("T_sample", "var")
%    T = T_sample
%end


%%%%%%%%%%%
% Method 1: Input transfer function
%C_s= (0.8665*s^2 + 1.98*s + 0.234)/(0.2315* s^2 + s)
%% Alternative Method : input parameters

%[num_C_s, den_C_s]  = numden(C_s);


%%%%%%%%%%%%%%%%%%%%%%
%% put in transfer function coefficients here
tf_numerator =  cont_num;    %%%%% numerator

tf_denomenator = cont_den; %%%%% numerator




%%%%%%%%%%%%%%%%
if any(tf_numerator) || any(tf_denomenator)
    sys = tf(tf_numerator, tf_denomenator)
    [Num,Den] = tfdata(sys);
    C_s = poly2sym(cell2mat(Num),s)/poly2sym(cell2mat(Den),s)
end


%C_s = (1.604 * s + 3.1) / (0.04812 * s + 1)


%%INITIALIZE VARIABLES
u_n_array_BD = 0; %% This will be the array for values
e_n_array_BD = 0; %% This will be the array
e_n_array_FD = 0;
u_n_array = 0;
syms u_n %% symbolic input
syms e_t %% symbolic error signal
syms u_0;   % Current Time input
syms u_1  % Previous time input
syms u_2   %time step from two steps ago
syms u_3 %time step from three steps ago
syms u_4 % time step from four steps ago

syms e_0 ; % Current Error siganl
syms e_1; % previous
syms e_2 %time step from two steps ago
syms e_3 ; %time step from three steps ago
syms e_4; %time step 4 steps ago

syms s % Laplace domain constant
syms q % Discrete domain constant
syms discrete_BD % Backwords difference s replacement
syms discrete_FD % Forward difference s replacement
syms discrete_CD % Central difference s replacement




%TIME CONSTANTS WHEN SWITCHING
discrete_BD = (q-1)/(T*q);
discrete_FD = (q - 1) / (T);
discrete_CD = (2*(q-1))/(T * (q + 1));




%% REWRITE FROM LAPLACE DOMAIN TO DISCRETE DOMAIN
C_s_BD =  subs(C_s, s, discrete_BD)



%% extract coeffecients into  two arrays
[num_BD, den_BD] = numden(C_s_BD);



%%Starting with FD discretization
C_s_FD = subs(C_s, s, discrete_FD);


[num_FD, den_FD] = numden(C_s_FD);

num_FD_coeffs = flip((coeffs(num_FD, q)));
den_FD_coeffs = flip((coeffs(den_FD, q)));

%% for 1/(s + 3)^2
%3 numbers in denominator - q^2 + 5q +1 and zero in numerator
%dvs. the difference in length is needed to be added in numerator


%% The length is how many q components in the denominator
den_FD_length = length(den_FD_coeffs);
num_FD_length = length(num_FD_coeffs);

length_difference = (den_FD_length - num_FD_length);
% things are different depending on the sign of length difference


if length_difference > 0 %% DVS flere led i denominator
    
    length_FD = den_FD_length
    e_n_FD_array = sym(zeros(length_FD, 1)) % A symbolic array as to be remade so that the t values can go in
    for i = length_FD:-1:length_difference + 1 %% This means one number gets iteratorated over
        e_n_FD_array(i) = num_FD_coeffs(i-length_difference)
        %%u_n svarer til denominator
        %%e_n svarer til numerator
    end
    
    u_n_FD_array = den_FD_coeffs
    
elseif length_difference < 0 %% DVS flere led i numerator
    length_FD = num_FD_length
    length_difference = abs(length_difference)
    u_n_FD_array = sym(zeros(length_FD, 1)) % A symbolic array as to be remade so that the t values can go in
    for i = length_FD:-1:length_difference + 1 %% This means one number gets iteratorated over
        i
        den_FD_coeffs(i-length_difference)
        u_n_FD_array(i) = den_FD_coeffs(i-length_difference)
        %%u_n svarer til denominator
        %%e_n svarer til numerator
    end
    
    e_n_FD_array = num_FD_coeffs
    
else
    length_FD = num_FD_length
    e_n_FD_array = num_FD_coeffs %% q^-1
    u_n_FD_array = den_FD_coeffs %% q^0, q^-1 
end



%% This creates the B(q) equation based off of the number of error signals
if den_FD_length == 1
    B_q_FD =u_0 *  u_n_FD_array(1);
elseif den_FD_length == 2
    B_q_FD= u_0 * u_n_FD_array(1)  + u_n_FD_array(2) * u_1;
elseif den_FD_length == 3
    B_q_FD = u_0 * u_n_FD_array(1)  + u_n_FD_array(2) * u_1 + u_n_FD_array(3) * u_2;
elseif den_FD_length == 4
    B_q_FD = u_0 * u_n_FD_array(1)  + u_n_FD_array(2) * u_1 + u_n_FD_array(3) * u_2 + u_n_FD_array(4) * u_3;
elseif den_FD_length == 5
    B_q_FD = u_0 * u_n_FD_array(1)  + u_n_FD_array(2) * u_1 + u_n_FD_array(3) * u_2 + u_n_FD_array(4) * u_3 +  u_n_FD_array(5) * u_4;
end

%% This creates the A(q) equation and
if length_FD == 1
    A_q_FD = e_n_FD_array(1) * e_0;
elseif length_FD == 2
    A_q_FD = e_n_FD_array(1)* e_0  + e_n_FD_array(2) * e_1;
elseif length_FD == 3
    A_q_FD = e_n_FD_array(1)* e_0  + e_n_FD_array(2) * e_1 + e_n_FD_array(3) * e_2;
elseif length_FD == 4
    A_q_FD = e_n_FD_array(1) * e_0 + e_n_FD_array(2) * e_1 + e_n_FD_array(3) * e_2 + e_n_FD_array(4) * e_3;
elseif length_FD == 5
    A_q_FD = e_0 * e_n_FD_array(1)  + e_n_FD_array(2) * e_1 + e_n_FD_array(3) * e_2 + e_n_FD_array(4) * e_3  + e_n_FD_array(5) * e_4;
end


u_n_FD = solve(A_q_FD == B_q_FD, u_0); %%
%% e_n_array_BD(1) svarer til e_n | e_n_array_BD(2) svarer til e_n-1

if isnumeric(T)
    e_n_FD_array = double(e_n_FD_array./u_n_FD_array(1));
    %% u_n_array_BD(1) svarer til e_n-1 | e_n_array_BD(2) svarer til u_n-2
    u_n_FD_array = double(- u_n_FD_array(2:end) / u_n_FD_array(1));
else
    e_n_FD_array = (e_n_FD_array./u_n_FD_array(1));
    %% u_n_array_BD(1) svarer til e_n-1 | e_n_array_BD(2) svarer til u_n-2
    u_n_FD_array = - u_n_FD_array(2:end) / u_n_FD_array(1);
end








%This is for Backwards Difference
num_BD_coeffs =  flip((coeffs(num_BD, q)));  %% A(q)
den_BD_coeffs = flip(coeffs(den_BD, q));  %% B(q)




%%ISOLATE INPUT AND OUTPUT SIGNALS
% f(q) = A(q) / B(q)

% A(q) * U_n = B(q) * e_t

num_length = length(num_BD_coeffs);%% this is how many values will be saved
den_length = length(den_BD_coeffs);


%% This creates the B(q) equation based off of the number of error signals
if den_length == 1
    u_n_array_BD = den_BD_coeffs(1);
    B_q =u_0 *  den_BD_coeffs(1);
elseif den_length == 2
    B_q = u_0 * den_BD_coeffs(1)  + den_BD_coeffs(2) * u_1;
    u_n_array_BD = den_BD_coeffs(1:2);
elseif den_length == 3
    B_q = u_0 * den_BD_coeffs(1)  + den_BD_coeffs(2) * u_1 + den_BD_coeffs(3) * u_2;
    u_n_array_BD = den_BD_coeffs(1:3);
elseif den_length == 4
    B_q = u_0 * den_BD_coeffs(1)  + den_BD_coeffs(2) * u_1 + den_BD_coeffs(3) * u_2 + den_BD_coeffs(4) * u_3;
    u_n_array_BD = den_BD_coeffs(1:4);
    
elseif den_length == 5
    B_q = u_0 * den_BD_coeffs(1)  + den_BD_coeffs(2) * u_1 + den_BD_coeffs(3) * u_2 + den_BD_coeffs(4) * u_3 +  den_BD_coeffs(5) * u_4;
    u_n_array_BD = den_BD_coeffs(1:5);
end

%% This creates the A(q) equation and
if num_length == 1
    A_q = num_BD_coeffs(1) * e_0;
    e_n_array_BD = (num_BD_coeffs(1));
elseif num_length == 2
    A_q = num_BD_coeffs(1)* e_0  + num_BD_coeffs(2) * e_1;
    e_n_array_BD = num_BD_coeffs(1:2);
    
elseif num_length == 3
    A_q = num_BD_coeffs(1)* e_0  + num_BD_coeffs(2) * e_1 + num_BD_coeffs(3) * e_2;
    e_n_array_BD = num_BD_coeffs(1:3);
    
elseif num_length == 4
    A_q = num_BD_coeffs(1) * e_0 + num_BD_coeffs(2) * e_1 + num_BD_coeffs(3) * e_2 + num_BD_coeffs(4) * e_3;
    e_n_array_BD = num_BD_coeffs(1:4);
elseif num_length == 5
    A_q = u_0 * den_BD_coeffs(1)  + den_BD_coeffs(2) * u_1 + den_BD_coeffs(3) * u_2 + den_BD_coeffs(4) * u_3  + den_BD_coeffs(5) * u_4;
    e_n_array_BD = num_BD_coeffs(1:5);
    
end








u_n = solve(A_q == B_q, u_0);
%% e_n_array_BD(1) svarer til e_n | e_n_array_BD(2) svarer til e_n-1
if isnumeric(T)
    e_n_array_BD = double(e_n_array_BD./u_n_array_BD(1));
    %% u_n_array_BD(1) svarer til e_n-1 | e_n_array_BD(2) svarer til u_n-2
    u_n_array_BD = double(- u_n_array_BD(2:end) / u_n_array_BD(1));
    
else
    
    e_n_array_BD = (e_n_array_BD./u_n_array_BD(1));
    %% u_n_array_BD(1) svarer til e_n-1 | e_n_array_BD(2) svarer til u_n-2
    u_n_array_BD = - u_n_array_BD(2:end) / u_n_array_BD(1);
    
end


if num_FD_length > den_FD_length
FD_length = num_FD_length;
else 
    FD_length = den_FD_length;
end



% The controller array in the first two arrays are decided by the type
% defined in NonLinearModelParameters
if disc_type == 1
discrete_constants = zeros(4, FD_length);
discrete_constants(1) = u_n_FD_array;
discrete_constants(2, 1:end) = e_n_FD_array;
discrete_constants(3) = u_n_array_BD;
discrete_constants(4, 1:end) = e_n_array_BD;
else
discrete_constants = zeros(4, FD_length);
discrete_constants(3) = u_n_FD_array;
discrete_constants(4, 1:end) = e_n_FD_array;
discrete_constants(1) = u_n_array_BD;
discrete_constants(2, 1:end) = e_n_array_BD;
end

%discrete_constants = [u_n_FD_array; e_n_FD_array; u_n_array_BD; e_n_array_BD]









