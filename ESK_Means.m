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
%任意选4个点。
Point(:,1)=X(:,1);
Point(:,2)=X(:,2);
Point(:,3)=X(:,3);
Point(:,4)=X(:,4);
diedaicishu=0;%迭代次数

while 1==1

  %求质心
  center1=[0;0];
  p1=0;
  center2=[0;0];
   p2=0;
  center3=[0;0];
    p3=0;
  center4=[0;0];
    p4=0;
   for i=1:1:N 
    if OuDis(Point(:,1),X(:,i))<OuDis(Point(:,2),X(:,i)) &&  OuDis(Point(:,1),X(:,i))<OuDis(Point(:,3),X(:,i)) &&  OuDis(Point(:,1),X(:,i))<OuDis(Point(:,4),X(:,i))
        center1(1)=X(1,i)+center1(1);
        center1(2)=X(2,i)+center1(2);
        p1=p1+1;
    end
    if OuDis(Point(:,2),X(:,i))<OuDis(Point(:,1),X(:,i)) &&  OuDis(Point(:,2),X(:,i))<OuDis(Point(:,3),X(:,i)) &&  OuDis(Point(:,2),X(:,i))<OuDis(Point(:,4),X(:,i))
        center2(1)=X(1,i)+center2(1);
        center2(2)=X(2,i)+center2(2);
        p2=p2+1;
    end
    if OuDis(Point(:,3),X(:,i))<OuDis(Point(:,2),X(:,i)) &&  OuDis(Point(:,3),X(:,i))<OuDis(Point(:,1),X(:,i)) &&  OuDis(Point(:,3),X(:,i))<OuDis(Point(:,4),X(:,i))
        center3(1)=X(1,i)+center3(1);
        center3(2)=X(2,i)+center3(2);
        p3=p3+1;
    end
    if OuDis(Point(:,4),X(:,i))<OuDis(Point(:,2),X(:,i)) &&  OuDis(Point(:,4),X(:,i))<OuDis(Point(:,3),X(:,i)) &&  OuDis(Point(:,4),X(:,i))<OuDis(Point(:,1),X(:,i))
        center4(1)=X(1,i)+center4(1);
        center4(2)=X(2,i)+center4(2);
        p4=p4+1;
    end
   end
   center1=center1/p1;
   center2=center2/p2;
   center3=center3/p3;
   center4=center4/p4;
   if OuDis(center1,Point(:,1))<0.01 &&  OuDis(center2,Point(:,2))<0.01 && OuDis(center3,Point(:,3))<0.01 && OuDis(center4,Point(:,4))<0.01
       break;
   else
       %继续
       out(1)= OuDis(center1,Point(:,1));
       out(2)= OuDis(center2,Point(:,2));
       out(3)= OuDis(center3,Point(:,3));
       out(4)= OuDis(center4,Point(:,4));
     
   
   
    
       Point(:,1)=center1;
       Point(:,2)=center2;
       Point(:,3)=center3;
       Point(:,4)=center4;
   end
    
     diedaicishu=diedaicishu+1;
end
diedaicishu  

t=toc
C1=[];
p1=1;
C2=[];
p2=1;
C3=[];
p3=1;
C4=[];
p4=1;

 for i=1:1:N 
    if OuDis(Point(:,1),X(:,i))<OuDis(Point(:,2),X(:,i)) &&  OuDis(Point(:,1),X(:,i))<OuDis(Point(:,3),X(:,i)) &&  OuDis(Point(:,1),X(:,i))<OuDis(Point(:,4),X(:,i))
        C1(p1)=i;
        p1=p1+1;
    end
    if OuDis(Point(:,2),X(:,i))<OuDis(Point(:,1),X(:,i)) &&  OuDis(Point(:,2),X(:,i))<OuDis(Point(:,3),X(:,i)) &&  OuDis(Point(:,2),X(:,i))<OuDis(Point(:,4),X(:,i))
        C2(p2)=i;
        p2=p2+1;
    end
    if OuDis(Point(:,3),X(:,i))<OuDis(Point(:,2),X(:,i)) &&  OuDis(Point(:,3),X(:,i))<OuDis(Point(:,1),X(:,i)) &&  OuDis(Point(:,3),X(:,i))<OuDis(Point(:,4),X(:,i))
        C3(p3)=i;
        p3=p3+1;
    end
    if OuDis(Point(:,4),X(:,i))<OuDis(Point(:,2),X(:,i)) &&  OuDis(Point(:,4),X(:,i))<OuDis(Point(:,3),X(:,i)) &&  OuDis(Point(:,4),X(:,i))<OuDis(Point(:,1),X(:,i))
        C4(p4)=i;
        p4=p4+1;
    end
 end

 sN=floor(N/4);
 

flag=1;
C=cell(1,4);
C{1}=C1;
C{2}=C2;
C{3}=C3;
C{4}=C4; 
while flag~=0
flag=0;
for g=1:1:4
[m,n1]=size(C{1});
[m,n2]=size(C{2});
[m,n3]=size(C{3});
[m,n4]=size(C{4});
nn(1)=n1;
nn(2)=n2;
nn(3)=n3;
nn(4)=n4;
   min=20000;
   minN=0;
   minC=0;
   minCN=0;
  if nn(g)<sN
    for i=1:1:4
         % 每个簇开始
      if i==g || nn(i)<=sN
          continue;
      else
          for j=1:1:nn(i)
             if OuDis(Point(:,g),X(:,C{i}(j)))<min
                min=OuDis(Point(:,g),X(:,C{i}(j)));
                minN=C{i}(j);
                minC=i;
                minCN=j;
                flag=1;
             end 
          end
      end
    end
    %找到后插入到当前簇
    nn(g)=nn(g)+1;
    C{g}(nn(g))=minN;
    C{minC}(minCN)=[];% 从原来的簇删除
  end
  
  
end

end
C1=C{1};
C2=C{2};
C3=C{3};
C4=C{4};




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



%求簇头
[m,n]=size(C1);
CH1=C1(1);
min=100000;
for i=1:1:n
   if OuDis(X(:,C1(i)),Point(:,1))<min
       min= OuDis(X(:,C1(i)),Point(:,1));
       CH1=C1(i);
   end
end
[m,n]=size(C2);
CH2=C2(1);
min=100000;
for i=1:1:n
     if OuDis(X(:,C2(i)),Point(:,2))<min
       min= OuDis(X(:,C2(i)),Point(:,2));
       CH2=C2(i);

   end
end

[m,n]=size(C3);
CH3=C3(1);
min=100000;
for i=1:1:n
      if OuDis(X(:,C3(i)),Point(:,3))<min
       min= OuDis(X(:,C3(i)),Point(:,3));
       CH3=C3(i);
   end
end
[m,n]=size(C4);
CH4=C4(1);
min=100000;
for i=1:1:n
       if OuDis(X(:,C4(i)),Point(:,4))<min
       min= OuDis(X(:,C4(i)),Point(:,4));
       CH4=C4(i);
   end
end





figure(1);
hold on;
[m,n]=size(C1);
sum=0;
sum2=0;
for i=1:1:n
    sum=sum+Distance(C1(i),CH1)*Distance(C1(i),CH1);
    sum2=sum2+OuDis(X(:,C1(i)),Point(:,1));
    if C1(i)==CH1
   %      plot(X(1,C1(i)),X(2,C1(i)),'k p','markersize',10);
    end
     plot(X(1,C1(i)),X(2,C1(i)),'k o','markersize',3);
end
[m,n]=size(C2);
for i=1:1:n
    sum=sum+Distance(C2(i),CH2)*Distance(C2(i),CH2);
    sum2=sum2+OuDis(X(:,C2(i)),Point(:,2));
    if C2(i)==CH2
       %  plot(X(1,C2(i)),X(2,C2(i)),'k p','markersize',10);
    end
     plot(X(1,C2(i)),X(2,C2(i)),'k x','markersize',3);
end

[m,n]=size(C3);
for i=1:1:n
    sum=sum+Distance(C3(i),CH3)*Distance(C3(i),CH3);
    sum2=sum2+OuDis(X(:,C3(i)),Point(:,3));
    if C3(i)==CH3
      %   plot(X(1,C3(i)),X(2,C3(i)),'k p','markersize',10);
    end
     plot(X(1,C3(i)),X(2,C3(i)),'k +','markersize',3);
end
[m,n]=size(C4);
for i=1:1:n
    sum=sum+Distance(C4(i),CH4)*Distance(C4(i),CH4);
    sum2=sum2+OuDis(X(:,C4(i)),Point(:,4));
    if C4(i)==CH4
      %   plot(X(1,C4(i)),X(2,C4(i)),'k p','markersize',10);
    end
     plot(X(1,C4(i)),X(2,C4(i)),'k *','markersize',3);
end

%plot(Point(1,1),Point(2,1),'k o','markersize',10);
%plot(Point(1,2),Point(2,2),'k o','markersize',10);
%plot(Point(1,3),Point(2,3),'k o','markersize',10);
%plot(Point(1,4),Point(2,4),'k o','markersize',10);

set(gca,'xlim',[0,100]);
set(gca,'ylim',[0,100]);
xlabel('X-coordinate','FontSize',10);
ylabel('Y-coordinate','FontSize',10);
title('ESK-Means','FontSize',10);
hold off;

   sum=sum/N
   sum2=sum2/N
   
