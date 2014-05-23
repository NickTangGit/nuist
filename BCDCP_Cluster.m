%%随机生成无线传感网络分布。
load TestData.mat X
%X=X(:,5:10);
[~,N]=size(X);
tic;
for i=1:1:N
    for j=1:1:N % 节点j到节点i的距离
        if i~=j
           Distance(i,j)=((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2)^0.5;
        else
           Distance(i,j)=0;
        end
    end
end

[m,~,v]=TwoDMax(Distance);


%寻找离m点最近的前N-K个节点
K=floor(N/2);
V=Distance(:,m);
T=1:1:N;
tt=0;
tv=0;
for i=1:1:N
    for j=2:1:N
       if V(j)<V(j-1)
           tt=T(j);
           tv=V(j);
           T(j)=T(j-1);
           V(j)=V(j-1);
           T(j-1)=tt;
           V(j-1)=tv;
       end
    end
    
end





%第一次分簇结果TC1,TC2
TC1=T(1:N-K);


TC2=T(N-K+1:N);





STC1=TC1;
STC2=TC2;
%求TC1分簇
A=1;
B=1;
for i=1:1:(N-K)
    for j=1:1:(N-K)
       if Distance(TC1(i),TC1(j))>Distance(TC1(A),TC1(B))
              A=i;
              B=j;
       end
    end
end

K1=floor((N-K)/2);
tt=0;
tv=0;
TV1=[];
for i=1:1:N-K
  TV1(i)=Distance(TC1(i),TC1(A));
end


for i=1:1:K1
    for j=2:1:(N-K)
      if TV1(j)<TV1(j-1)
         tt=TC1(j);
         tv=TV1(j);
         TC1(j)=TC1(j-1);
         TV1(j)=TV1(j-1);
         TC1(j-1)=tt;
         TV1(j-1)=tv;
      end
    end
end
C1=TC1(1:N-K-K1);
C2=TC1(N-K-K1+1:N-K);


% 求TC2分簇
A=1;
B=1;
for i=1:1:K
    for j=1:1:K
       if Distance(TC2(i),TC2(j))>Distance(TC2(A),TC2(B))
              A=i;
              B=j;
       end
    end
end

K2=floor((K)/2);
tt=0;
tv=0;
TV2=[];
for i=1:1:K
  TV2(i)=Distance(TC2(i),TC2(A));
end


for i=1:1:K2
    for j=2:1:K
      if TV2(j)<TV2(j-1)
         tt=TC2(j);
         tv=TV2(j);
         TC2(j)=TC2(j-1);
         TV2(j)=TV2(j-1);
         TC2(j-1)=tt;
         TV2(j-1)=tv;
      end
    end
end
C3=TC2(1:K-K2);
C4=TC2(K-K2:K);
t=toc




%求每个簇的质心
Point(:,1)=[0;0];
Point(:,2)=[0;0];
Point(:,3)=[0;0];
Point(:,4)=[0;0];

[m,n]=size(C1);
for i=1:1:n
  Point(1,1)=X(1,C1(i))+Point(1,1);
  Point(2,1)=X(2,C1(i))+Point(2,1);
end
Point(:,1)=Point(:,1)/n ;
[m,n]=size(C2);
for i=1:1:n
  Point(1,2)=X(1,C2(i))+Point(1,2);
  Point(2,2)=X(2,C2(i))+Point(2,2);
end
Point(:,2)=Point(:,2)/n ;
[m,n]=size(C3);
for i=1:1:n
  Point(1,3)=X(1,C3(i))+Point(1,3);
  Point(2,3)=X(2,C3(i))+Point(2,3);
end
Point(:,3)=Point(:,3)/n ;
[m,n]=size(C4);
for i=1:1:n
  Point(1,4)=X(1,C4(i))+Point(1,4);
  Point(2,4)=X(2,C4(i))+Point(2,4);
end
Point(:,4)=Point(:,4)/n ;




figure(1);
hold on;
[m,n]=size(C1);
sum=0;
sum2=0;
randCH=n*ceil(rand(1,1));
randCH=C1(randCH);
for i=1:1:n
    sum=sum+Distance(C1(i),randCH)*Distance(C1(i),randCH);
    sum2=sum2+OuDis(X(:,C1(i)),Point(:,1));
     plot(X(1,C1(i)),X(2,C1(i)),'k o','markersize',3);
end
[m,n]=size(C2);
randCH=n*ceil(rand(1,1));
randCH=C2(randCH);
for i=1:1:n
      sum=sum+Distance(C2(i),randCH)*Distance(C2(i),randCH);
       sum2=sum2+OuDis(X(:,C2(i)),Point(:,2));
     plot(X(1,C2(i)),X(2,C2(i)),'k x','markersize',3);
end

[m,n]=size(C3);
randCH=n*ceil(rand(1,1));
randCH=C3(randCH);
for i=1:1:n
     sum=sum+Distance(C3(i),randCH)*Distance(C3(i),randCH);
     sum2=sum2+OuDis(X(:,C3(i)),Point(:,3));
     plot(X(1,C3(i)),X(2,C3(i)),'k +','markersize',3);
end
[m,n]=size(C4);
randCH=n*ceil(rand(1,1));
randCH=C4(randCH);
for i=1:1:n
      sum=sum+Distance(C4(i),randCH)*Distance(C4(i),randCH);
       sum2=sum2+OuDis(X(:,C4(i)),Point(:,4));
     plot(X(1,C4(i)),X(2,C4(i)),'k *','markersize',3);
end


AliveNodesPerRound=OrgGAF_D;
save('BCDCP_LiveNode.mat','AliveNodesPerRound');
save('BCDCP_Energy.mat','EnergyPerRound');
LastRound=round-1;
FirstRound
FirstClusterDie
LastRound
lifetime


set(gca,'xlim',[0,100]);
set(gca,'ylim',[0,100]);
xlabel('X-coordinate','FontSize',10);
ylabel('Y-coordinate','FontSize',10);
title('BCDCP迭代分割法','FontSize',10);
hold off;
sum=sum/N
sum2=sum2/N

