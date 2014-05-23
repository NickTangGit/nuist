clc;
load GAF_LiveNode.mat AliveNodesPerRound;
DT_C=AliveNodesPerRound;
load GBP_LiveNode.mat AliveNodesPerRound;
GEAR_CC=AliveNodesPerRound;
[m,n]=size(GEAR_CC);
GEAR_CC(n)=75;
[m,n]=size(DT_C);
DT_C(n)=75;

load BCDCP_LiveNode.mat AliveNodesPerRound;
CHtoCH=AliveNodesPerRound;
[m,n]=size(CHtoCH);
CHtoCH(n)=75;
figure(1);
hold on;

plot(DT_C,'k :','LineWidth',1,'MarkerSize',1);
plot(CHtoCH,'k -.','LineWidth',2,'MarkerSize',1);
plot(GEAR_CC,'k -','LineWidth',1,'MarkerSize',1);

xlabel('轮数','FontSize',10);
ylabel('存活节点个数','FontSize',10);
set(gca,'ylim',[75,105]);
legend('LEACH-C','BCDCP','GOR');
hold off;