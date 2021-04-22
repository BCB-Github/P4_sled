function y = CurrentOffset(u)
if abs(u) < 1e-3
   y=0;
else
%y = u+(sign(u)*0.745);

if abs(u(2)) < 1e-3
    
    y=u(1) + sign(u(1)) * 0.4294;
    
else
    y = u(1)+(sign(u(2))*0.4294);
end
end
