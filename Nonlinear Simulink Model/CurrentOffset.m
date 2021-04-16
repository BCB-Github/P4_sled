function y = fcn(u)
if abs(u) < 1e-2;
    y=0;
else
%y = u+(sign(u)*0.745);
y = u+(sign(u)*0.4294);
end
