clc;
load GAF_Energy.mat EnergyPerRound;
A1=EnergyPerRound;
load GBP_Energy.mat EnergyPerRound;
A2=EnergyPerRound;
load BCDCP_Energy.mat EnergyPerRound;
A3=EnergyPerRound;

[m,a1]=size(A1);
[m,a2]=size(A2);
[m,a3]=size(A3);
figure(1);
hold on;
A1 =A1*0.98;
A2 =A2*0.98;
A3 =A3*0.98;
plot(A1,'k --','LineWidth',2,'MarkerSize',1);
plot(A3,'k -.','LineWidth',2,'MarkerSize',1);
plot(A2,'k -','LineWidth',2,'MarkerSize',1);


xlabel('轮数','FontSize',10);
ylabel('平均耗能总量','FontSize',10);
set(gca,'ylim',[0,1]);
legend('LEACH-C','BCDCP','GOR');
line([a1,0],[A1(a1),A1(a1)],'color',[0.5 0.5 0.5],'LineWidth',1);
line([a1,a1],[A1(a1),0],'color',[0.5 0.5 0.5],'LineWidth',1);

line([a2,0],[A2(a2),A2(a2)],'color',[0.5 0.5 0.5],'LineWidth',1);
line([a2,a2],[A2(a2),0],'color',[0.5 0.5 0.5],'LineWidth',1);

line([a3,0],[A3(a3),A3(a3)],'color',[0.5 0.5 0.5],'LineWidth',1);
line([a3,a3],[A3(a3),0],'color',[0.5 0.5 0.5],'LineWidth',1);
hold off;