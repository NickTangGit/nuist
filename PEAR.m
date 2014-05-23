clc;
clear;
%% 建立一个网络
% N=100;%（传感器节点个数）
EnergyThreshold=1000000;%能量总额（阀门）10^(-6) J

load TestDataforPear.mat X
[~,N]=size(X);
maprange=100;%地图尺寸
PositionSet=[0,0];
X(1,N+1)=PositionSet(1);%5个传感器节点的坐标  最后一个sink=[10;10];%汇聚节点的坐标
X(2,N+1)=PositionSet(2);

%    X(3,i) X第三行为每个节点的固定标识，用数字表示
%    X(4,i) X第四行 表示每个节点是否死亡，1代表活着，0代表死亡，初始化都活着
%    X(5,i) X第五行 表示每个节点是否被访问，1代表访问过，0代表为访问，初始化都未访问
%    X(6,i) EnergyThreshold;%X第6行， 表示每个节点的剩余能量

DisBasetoCenter=((PositionSet(1)-50)^2+(PositionSet(2)-50)^2)^0.5;

[pcount,~]=size(PositionSet);


r=50;%通信半径
Nc=4;%簇的个数
flag=[25 25 25 25];



Cluster=cell(1,4);%元胞数组，记录4个簇
for i=1:1:100
  [csize,~]=size(Cluster{X(3,i)});
   Cluster{X(3,i)}(csize+1) ==i;
end

%% 能量定义
Eelec=0.05;%每发送或者接受1bit信息的数据需要耗费的能量 0.05 * 10^(-6) 
Eamp=0.0001;%一米的距离，传输1bit信息的数据需要耗费的能量 0.4 * 10^(-6)
BitsPerTime=2000;%普通节点每次需要提交的bit数
OrderLength=26;% 假设基于查询的路由所有的命令长度都是16bit
NoteIDLength=8;% 节点号的长度，i从1开始到N+1，表示下一跳节点为i，i=N+1时表示下一跳为汇聚节点
EnergyPerTrans=BitsPerTime*Eamp;%每次每米传输BitsPerTime个数据需要的能量。
EnergyPerSend=Eelec*BitsPerTime;%每次发送BitsPerTime个数据需要的能量。
EnergyPerReceive=Eelec*BitsPerTime;%中间节点每次接收其他节点的BitsPerTime个数据需要的能量。
EnergyReceiveOrder=Eelec*(OrderLength);%每次的命令由三个字段组成，其可能情况如下（支持扩展）：
% Order（命令）    Receive ID（命令发送对象节点ID）   Relative ID（相关ID号）
% 01 00              XX                                   YY                  01表示该条命令为查询命令，查询字段为：00（温度），（基站把查询消息告诉XX，并且告诉他把数据发送给YY即可）
% 01 01              XX                                   YY                  01表示该条命令为查询命令，查询字段为：01（湿度）
% 01 XX              XX                                   YY                  01表示该条命令为查询命令，查询字段为：XX（其他）
% 02 00              AA                                   BB                  02表示该条命令为设置下一跳命令（也就是设置AA的下一跳为BB，那么一旦AA有数据需要发送，则把数据发送给BB），查询字段为：00（温度），并且
%% 计算每两个节点之间的传输信息的花费，我们用距离的平方来计算。
% cost(i,j) 表示第j个节点传输BitsPerTime量的数据信息到i，所花费的传输能量。
for i=1:1:N+1
    for j=1:1:N+1 % 节点j到节点i的距离
        if i~=j
           cost2(i,j)=EnergyPerTrans*((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2);% 可以拓展为能量消耗函数
           Distance(i,j)=((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2)^0.5;
        else
           cost2(i,j)=0;
           Distance(i,j)=0;
        end
    end
end

%每轮：
%首先在汇聚节点上进行分簇和簇头选择（每次选择剩余能量最大的节点作为簇头节点）
%1.活着每个节点都会接受一条命令
%2.除簇头之外的每个节点都会发送BitsPerTime量的数据信息到其所属簇的簇头
%3.簇头接受所有的簇内成员发送来的数据。
%3.1 簇头进行数据融合，把簇内的所有数据融合到簇头上的一个BitsPerTime量的数据信息，该过程耗能不计
%4.簇头通过GBP 将数据传送到sink

%所以每轮的耗能：
%1.簇头节点：P剩余=P原来-接受sink命令耗能-簇内其他成员数目*接受BitsPerTime量的数据信息耗能-发射BitsPerTime量的数据信息耗能-传输BitsPerTime量的数据信息到下一跳的耗能
%2.非簇头节点：P剩余=P原来-接受sink命令耗能-发射BitsPerTime量的数据信息耗能-传输BitsPerTime量的数据信息到簇头的耗能
C_size=flag; %记录每个簇的节点个数
round=1;%第一轮
FirstRound=-1;
FirstClusterDieRound=-1;
[m_Num,~]=max(C_size);%m_Num 表示C_size（簇尺寸）数组里最大簇的尺寸，只要这个尺寸大于0，则说明该群体还存活着。
RestX=X(1:5,:);
RestE=X(6,1:N);
livecount=N;%>0,则说明该群体还存活着。
EnergyPerRound=0;
lifetime=0;
dddddd=0;
CH=[];
while m_Num>0
    tx=0;
    for li=1:1:Nc
        if C_size(li)>0
            for lj=1:1:C_size(li)
            if Cluster{li}(6,lj)<=15
                Cluster{li}(6,lj)=0;
            end
            tx=tx+Cluster{li}(6,lj);
            end
        end
    end
    EnergyPerRound(round)=((EnergyThreshold*100)-tx)/(EnergyThreshold*100);
    %得出每个簇的簇头(选择剩余能量最大的),并且计算每个簇节点的剩余能量
    C_num=1;%用于记录簇头在簇头数组的标号
    CH=[];%清空簇头
    ECC=[0,0];
    for j=1:1:Nc %对每个簇进行操作
      if C_size(j)<=0
          continue;
      end
      [~,mc]=max(Cluster{j}(6,:));%选择剩余能量最大的作为簇头
      CH(:,C_num)=[Cluster{j}(:,mc);mc;j];% CH的第7行记录了该簇头在该簇中的位置，第8行记录了簇号
      C_num=C_num+1;
      %每个簇头要接受簇内所有节点的信息必须要花费的能量为：(C_size(j)-1)*EnergyPerReceive。所以先行减去。
      Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1)*EnergyPerReceive;
    %  Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1)*EnergyPerReceive-5*EnergyPerSend-5*cost2(N+1,Cluster{j}(3,mc));
  
          
      
      ECC(1)=ECC(1)+(C_size(j)-1)*EnergyPerReceive;%统计量
      ECC(2)=ECC(2)+5*EnergyPerSend+5*cost2(N+1,Cluster{j}(3,mc));
      if Cluster{j}(6,mc)<=0 %防止带入GBP_Train时的数值为负错误
          Cluster{j}(6,mc)=10;
      end
      index2=FindID(RestX(3,:),Cluster{j}(3,mc));
      if index2==0
         disp('1');
      end
      RestE(index2)=Cluster{j}(6,mc);
      % 更新非簇头的剩余能量
      for i=1:1:C_size(j)
          if i~=mc %求非簇头的剩余能量
              Cluster{j}(6,i)=Cluster{j}(6,i)-EnergyReceiveOrder-EnergyPerSend-cost2(Cluster{j}(3,mc),Cluster{j}(3,i));
              ECC(1)=ECC(1)+EnergyReceiveOrder+EnergyPerSend+cost2(Cluster{j}(3,mc),Cluster{j}(3,i));
               index2=FindID(RestX(3,:),Cluster{j}(3,i));
                  if index2==0
                     disp('1');
                  end
               RestE(index2)=Cluster{j}(6,i);
          end
      end
    end

 
%     for i=1:1:N
%         if RestE(i)<=15
%             
%             X(4,i)=0;
% 
%              if FirstRound==-1 %第一轮死亡出现
%               FirstRound=round;
%              end
%             
%         end
%     end
        
%% 更新簇头的剩余能量
    [~,C_num]=size(CH);
    ID_Index=[];
    ID_Index=CH(3,1:C_num);
    RestX(5,:)=0;  % 清空访问位 每轮开始时，至少可以保证这个这些节点都是活着的，因为只有活着才会被留下来

    for i=1:1:C_num %每一轮，对所有当前“活着”的簇头进行查询
       [~,CurSize]=size(RestX);
       k=FindID(RestX(3,1:CurSize-1),ID_Index(i));%在当前剩余的RestX节点ID数组(3,1:NN)中寻找ID为ID_Index(i)的节点，
       if  k==0%该节点已经死亡，在当前剩余的RestX找不到了，直接下一个
           continue;
       end
       %归一化RestE
       [Wmax,~]=max(RestE);
       TempWW=RestE/Wmax;
 
       RestX(1,CurSize)=PositionSet(1);
       RestX(2,CurSize)=PositionSet(2);   
       [~,Next,C,~,RestX,RestE]=GBP_Train(RestX,RestE,TempWW,Eelec,Eamp,5*BitsPerTime,OrderLength,NoteIDLength,k,DisBasetoCenter);
      
       
    end
  
      %更新簇成员
     for j=1:1:Nc%对每个簇进行操作      
      temp=[];
      p=1;
      IsClusterLive=0;
      tmp_Cs=C_size(j);
      for i=1:1:tmp_Cs
           index=FindID(RestX(3,:),Cluster{j}(3,i));%找出该节点所在RestX
           if index==0
             Cluster{j}(6,i)=0;%已经死亡
             C_size(j)=C_size(j)-1;
             index2=FindID(X(3,:),Cluster{j}(3,i));%找出节点所在X的ID号
             if index2==0
                disp('cao');
             end
             X(4,index2)=0;
              
                   if FirstRound==-1 %第一轮死亡出现
                     
                      FirstRound=round;
                   end
           else
             Cluster{j}(6,i)=RestE(index);
             temp(:,p)=Cluster{j}(:,i);
             p=p+1;
             IsClusterLive=1;%只要有节点活着，簇就活着。
           end
      end
      if IsClusterLive==0  && FirstClusterDieRound==-1; %有簇死亡
          FirstClusterDieRound=round;
      end
      Cluster{j}=[];
      Cluster{j}=temp;
     end

   livecount=0;
   for ii=1:1:N
       if X(4,ii)==1
           livecount=livecount+1;
           
           
       end
   end
   
   if livecount<75
      lifetime=round;
         figure(1);
hold on;

for i=1:1:N
    %text(X(1,i),X(2,i)',strcat(num2str(i),',  ',num2str(W(i))));%显示能量总额
    if X(4,i)==0
         plot(X(1,i),X(2,i),'r x','markersize', 10);
    else
          plot(X(1,i),X(2,i),'r o');  
    end
   
  %  text(X(1,i),X(2,i)',num2str(i));
end
%plot(X(1,N+1),X(2,N+1),'b *');
%text(X(1,N+1),X(2,N+1),'Sink');%6代表汇聚节点
set(gca,'xlim',[0,maprange]);
set(gca,'ylim',[0,maprange]);
hold off;
       
      
      
      
      break;
   end
   
    
   GBP_GAF_D(round)=livecount;   
   round=round+1   

  
   

end
AliveNodesPerRound=GBP_GAF_D;
save('GBP_LiveNode.mat','AliveNodesPerRound');
save('GBP_Energy.mat','EnergyPerRound');
LastRound=round-1;
FirstClusterDieRound
FirstRound
LastRound
lifetime
dddddd


