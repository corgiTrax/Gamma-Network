
% x = linspace(-0.05,1+0.05,1000);
% y = sin(2*pi*x);
% plot(x,y,'r','LineWidth',4)
% axis([-0.06 1+0.06 -1.2 1.2])
% hold
% 
% y2 = exp(-2*pi*x);
% plot(x, y2, 'c','LineWidth',4)


x = linspace(-0.1,1+0.1,1000);
y = sin(2*pi*x-0.5*pi);
plot(x,y,'r','LineWidth',4)
axis([-0.15 1+0.15 -1.2 1.2])
hold

% y2 = exp(-2*pi*x);
% plot(x, y2,'b','LineWidth',4)



xlabel('Gamma phase')
ylabel('Response magnitude')