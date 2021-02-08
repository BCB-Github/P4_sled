x = -10:1:100;

for i=1:length(x)
   x(i) = i^2-x(i)*sum(x)*0.0001*i-i;
end
plot(x)