%Denne fil definere de parametere vi skal bruge
%Egenskaber af systemet
syms s
digits(5)

%Resistans og induktans 12 volt faulhaber
Rm=5.45;
Lm=85*10^(-6);
J=0.15*10^(-7);
B=3.18*10^(-7);


%Elektrisk overfoeringsfunktion
elec_transfer = 1/(Lm*s+Rm);
[num, den] = numden(elec_transfer);
den=vpa(den/num);
elec_transfer_coef_num = [1];
elec_transfer_coef_den = coeffs(den,"All");

%strøm til torque gain

curr_torq_gain= 2.68e-3;

%torque til rads
torq_rads_num = [1];
torq_rads_den  = [J, B];

%rad til trans gain
rad_trans_gain = 0.05*(1/3)*(30/16);

%Back_emf_gain
back_emf_gain = 2.586e-2;