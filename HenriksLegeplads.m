x = 1:1:100;

for i=1:length(x)
   x(i) = i^2-x(i)* sum(x)*0.0001*i;
end
plot(x)