clc;
load GAF_Energy.mat EnergyPerRound;
A1=EnergyPerRound;
load GBP_Energy.mat EnergyPerRound;
A2=EnergyPerRound;
load BCDCP_Energy.mat EnergyPerRound;
A3=EnergyPerRound;

load GAF_LiveNode.mat AliveNodesPerRound;
DT_C=AliveNodesPerRound;
load GBP_LiveNode.mat AliveNodesPerRound;
GEAR_CC=AliveNodesPerRound;
[m,n]=size(GEAR_CC);
GEAR_CC(n)=75;
load BCDCP_LiveNode.mat AliveNodesPerRound;
BCDCP=AliveNodesPerRound;



[m,a1]=size(A1);
[m,a2]=size(A2);
[m,a3]=size(A3);

for i=1:1:a1-1
  Index1(i)=(A1(i+1)-A1(i));
end
Index1(a1)=Index1(a1-1);
for i=1:1:a2-1
  Index2(i)=(A2(i+1)-A2(i));%GEAR_CC(i)/
end
Index2(a2)=Index2(a2-1);
for i=1:1:a3-1
  Index3(i)=(A3(i+1)-A3(i));%BCDCP(i)
end
Index3(a3)=Index3(a3-1);

A1=Index1;
A2=Index2;
A3=Index3;

maxa1=max(A1);
maxa2=max(A2);
maxa3=max(A3);

maxx=max([maxa1,maxa2,maxa3]);
figure(1);
hold on;


plot(A1,'k o','MarkerSize',3);
plot(A3,'k d','MarkerSize',3);
plot(A2,'k .','MarkerSize',3);


xlabel('轮数','FontSize',10);
ylabel('每轮节点平均耗能','FontSize',10);
set(gca,'ylim',[0,maxx]);
legend('LEACH-C','BCDCP','GOR');
% line([a1,0],[A1(a1),A1(a1)],'color',[0.5 0.5 0.5],'LineWidth',1);
% line([a1,a1],[A1(a1),0],'color',[0.5 0.5 0.5],'LineWidth',1);
% 
% line([a2,0],[A2(a2),A2(a2)],'color',[0.5 0.5 0.5],'LineWidth',1);
% line([a2,a2],[A2(a2),0],'color',[0.5 0.5 0.5],'LineWidth',1);
% 
% line([a3,0],[A3(a3),A3(a3)],'color',[0.5 0.5 0.5],'LineWidth',1);
% line([a3,a3],[A3(a3),0],'color',[0.5 0.5 0.5],'LineWidth',1);
hold off;