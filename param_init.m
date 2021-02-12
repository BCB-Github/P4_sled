%Denne fil definere de parametere vi skal bruge
%Egenskaber af systemet
R_electrisk = 5
l = 0.5 



%Elektrisk overfoeringsfunktion

elec_transfer_coef_num = [1];
elec_transfer_coef_den = [85e-6 5.45];

%strøm til torque gain

curr_torq_gain= 2.68e-3;

%torque til rads
torq_rads_num = [1];
torq_rads_den  = [0.15e-7 3.18e-7];

%rad til trans gain
rad_trans_gain = 0.05*(1/3)*(30/16);

%Back_emf_gain
back_emf_gain = 2.586e-2;