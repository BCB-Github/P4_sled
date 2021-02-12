x = 1:1:12;

for i=1:length(x)
   x(i) = i^2-x(i)* sum(x);
end
plot(x)