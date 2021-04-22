function y = SignOfVelocity(u)
persistent uold
if isempty(uold)
    uold=0
end
diff = u-uold;

if diff > 1e-5
    y=1;
elseif diff < 1e-5 && diff >-1e-5
    y=0;
elseif diff < -1e-5
    y=-1;
end
uold=u

  

end