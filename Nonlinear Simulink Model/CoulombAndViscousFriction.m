function FricForce = CoulombAndViscousFriction(u)
%FRICTION Summary of this function goes here
% Input force må være u(1) og u(2) må være hastigheden

m = 0.546 + 0.14;            %Mass of sled system
mu = 0.366481157785306; %Coulumb friktionskoeficcienten.
b = 3.4; % Viscous friktionskoefficient
F_c = mu*m*9.8; %Coulomb friktion når blokken er i bævegelse.
F_v = b*abs(u(2));

if abs(u(2)) < 1e-3 %Hvis hastigheden er tæt på 0 sidder blokken fast
    if abs(u(1)) > F_c % Hvis størrelsen af indgangskraften er større end F_c så sidder blokken ikke fast 
        FricForce = -sign(u(2))*(F_v+F_c);
    else % Blokken sidder fas hvis størrelsen af u(1) er for lille
        FricForce = -u(1);
    end
else % hvis blokken ikke står stille, sidder den ikke fast.
    FricForce = -sign(u(2))*(F_v+F_c);
 

end

