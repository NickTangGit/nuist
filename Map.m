load TestData.mat X;
[~,N]=size(X);
maprange=100;
figure(1);
hold on;
plot(X(1,1:N),X(2,1:N),'r .');
for i=1:1:N
    %text(X(1,i),X(2,i)',strcat(num2str(i),',  ',num2str(W(i))));%显示能量总额
    text(X(1,i),X(2,i)',num2str(i));
end
%plot(X(1,N+1),X(2,N+1),'b *');
%text(X(1,N+1),X(2,N+1),'Sink');%6代表汇聚节点
set(gca,'xlim',[0,maprange]);
set(gca,'ylim',[0,maprange]);
hold off;