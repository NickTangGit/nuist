%%随机生成无线传感网络分布。
load TestData.mat X
%X=X(:,5:10);
[~,N]=size(X);
for i=1:1:N
    for j=1:1:N % 节点j到节点i的距离
        if i~=j
           Distance(i,j)=((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2)^0.5;
        else
           Distance(i,j)=0;
        end
    end
end

tic;
CH1=1;
CH2=2;
CH3=3;
CH4=4;
Existed(1,:)=[1,2,3,4];

T=300;
T_min=10;
r=0.99;
diedaicishu=0;

while T>T_min
    while 1==1%如果不合法，继续随机
         TCH=N*rand(1,4);
         TCH=ceil(TCH);
         for i=1:1:4%排序后放入
            for j=2:1:4
              if TCH(j)<TCH(j-1)
                 e=TCH(j-1);
                 TCH(j-1)=TCH(j);
                 TCH(j)=e;
              end
            end
         end
         
        if test(TCH(1),TCH(2),TCH(3),TCH(4))==0%如何test1合法
          if test2(TCH(1),TCH(2),TCH(3),TCH(4),Existed)==1%如果test2不合法继续随机
            continue;  
          else%test2合法，跳出循环
              break;
          end
        else
            continue;
        end     
    end
    CH1_1=TCH(1);
    CH2_1=TCH(2);
    CH3_1=TCH(3);
    CH4_1=TCH(4);
    
    %计算原先方案的熵值
    Cost1=SACost(CH1,CH2,CH3,CH4,Distance)/N;
    Cost2=SACost(CH1_1,CH2_1,CH3_1,CH4_1,Distance)/N;
    if(Cost1>Cost2)
       CH1=CH1_1;
       CH2=CH2_1;
       CH3=CH3_1;
       CH4=CH4_1;
       T=300;
    else
        dE=Cost1-Cost2;
        if exp(dE/T)>0.001
           
        else
            break;
        end
    end
    T=r*T
    diedaicishu=diedaicishu+1;
end

pc1=1;
pc2=1;
pc3=1;
pc4=1;
C1=[];
C2=[];
C3=[];
C4=[];
for i=1:1:N 
    if Distance(i,CH1)<Distance(i,CH2) && Distance(i,CH1)<Distance(i,CH3)  && Distance(i,CH1)<Distance(i,CH4)
        C1(pc1)=i;
        pc1=pc1+1;
    end
    if Distance(i,CH2)<Distance(i,CH1) && Distance(i,CH2)<Distance(i,CH3)  && Distance(i,CH2)<Distance(i,CH4)
        C2(pc2)=i;
        pc2=pc2+1;
    end
    if Distance(i,CH3)<Distance(i,CH1) && Distance(i,CH3)<Distance(i,CH2)  && Distance(i,CH3)<Distance(i,CH4)
        C3(pc3)=i;
        pc3=pc3+1;
    end
    if Distance(i,CH4)<Distance(i,CH2) && Distance(i,CH4)<Distance(i,CH3)  && Distance(i,CH4)<Distance(i,CH1)
        C4(pc4)=i;
        pc4=pc4+1;
    end
end
diedaicishu

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
for i=1:1:n
     sum=sum+Distance(C1(i),CH1)*Distance(C1(i),CH1);
     sum2=sum2+OuDis(X(:,C1(i)),Point(:,1));
     plot(X(1,C1(i)),X(2,C1(i)),'k o','markersize',3);
end
[m,n]=size(C2);
for i=1:1:n
     sum=sum+Distance(C2(i),CH2)*Distance(C2(i),CH2);
     sum2=sum2+OuDis(X(:,C2(i)),Point(:,2));
     plot(X(1,C2(i)),X(2,C2(i)),'k x','markersize',3);
end

[m,n]=size(C3);
for i=1:1:n
     sum=sum+Distance(C3(i),CH3)*Distance(C3(i),CH3);
     sum2=sum2+OuDis(X(:,C3(i)),Point(:,3));
     plot(X(1,C3(i)),X(2,C3(i)),'k d','markersize',3);
end
[m,n]=size(C4);
for i=1:1:n
     sum=sum+Distance(C4(i),CH4)*Distance(C4(i),CH4);
      sum2=sum2+OuDis(X(:,C4(i)),Point(:,4));
     plot(X(1,C4(i)),X(2,C4(i)),'k *','markersize',3);
end


set(gca,'xlim',[0,100]);
set(gca,'ylim',[0,100]);
xlabel('X-coordinate','FontSize',10);
ylabel('Y-coordinate','FontSize',10);
title('LEACH-C SA','FontSize',10);
hold off;


figure(2);
hold on;
for i=1:1:N
     plot(X(1,i),X(2,i),'k o','markersize',3);
end


set(gca,'xlim',[0,100]);
set(gca,'ylim',[0,100]);
xlabel('X-coordinate','FontSize',10);
ylabel('Y-coordinate','FontSize',10);
title('Map Model','FontSize',10);
hold off;



sum=sum/N
   sum2=sum2/N
