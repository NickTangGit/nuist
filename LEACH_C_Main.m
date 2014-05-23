clc;
clear;
%% 建立一个网络
% N=100;%（传感器节点个数）
EnergyThreshold=1000000;%能量总额（阀门）10^(-6) J

load TestDataforLEACH_C.mat X
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
           cost(i,j)=EnergyPerTrans*((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2);% 可以拓展为能量消耗函数
           Distance(i,j)=((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2)^0.5;
        else
           cost(i,j)=0;
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
%4.簇头通过直传把数据传输给汇聚节点
%所以每轮的耗能：
%1.簇头节点：P剩余=P原来-接受sink命令耗能-簇内其他成员数目*接受BitsPerTime量的数据信息耗能-发射BitsPerTime量的数据信息耗能-传输BitsPerTime量的数据信息到sink的耗能
%2.非簇头节点：P剩余=P原来-接受sink命令耗能-发射BitsPerTime量的数据信息耗能-传输BitsPerTime量的数据信息到簇头的耗能
C_size=flag; %记录每个簇的节点个数
round=1;%第一轮
FirstRound=-1;
[m_Num,~]=max(C_size);

FirstClusterDie=-1;
EnergyPerRound=0;
lifetime=0;

DeliverC=1;

while m_Num>0

    EnergyPerRound(round)=((EnergyThreshold*100)-sum(X(6,1:N)))/(EnergyThreshold*100);
    %得出每个簇的簇头(选择剩余能量最大的),并且计算每个簇节点的剩余能量
    CH_ID=[0,0,0,0];
    ECC=[0,0];
    
   for j=1:1:4 %对每个簇进行操作
       
      for k=1:1:4 %对每个簇进行操作
         [mcs,ncs]=size(Cluster{k});
         if(ncs==0)
             continue;
         else
         [mv,mc]=max(Cluster{k}(6,:));
          CH_ID(k)=mc;%记录的是簇数组内的坐标，不是节点ID
         end
      end 
       
      if C_size(j)<=0
          continue;
      end
      if C_size(1)<=0
          DeliverC=2;
          break;
      end
  
      [mv,mc]=max(Cluster{j}(6,:));
      
      PackageNum=5;
      
      % 更新簇头剩余能量
      if(DeliverC==1)
          
      if j==1  % 如果是第一个簇
          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1+3)*EnergyPerReceive-20*EnergyPerSend-20*cost(N+1,Cluster{j}(3,mc));
      end
      if j==2  % 如果是第2个簇
          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1+0)*EnergyPerReceive-PackageNum*EnergyPerSend-PackageNum*cost(Cluster{1}(3,CH_ID(1)),Cluster{j}(3,mc));
      end
      if j==3  % 如果是第3个簇
          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1+0)*EnergyPerReceive-PackageNum*EnergyPerSend-PackageNum*cost(Cluster{1}(3,CH_ID(1)),Cluster{j}(3,mc));
      end
      if j==4  % 如果是第4个簇
          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1+0)*EnergyPerReceive-PackageNum*EnergyPerSend-PackageNum*cost(Cluster{1}(3,CH_ID(1)),Cluster{j}(3,mc));
      end
      end
      
   
          
      
         X(6,Cluster{j}(3,mc))=Cluster{j}(6,mc);
      for i=1:1:C_size(j)
          if i~=mc %求非簇头的剩余能量
              Cluster{j}(6,i)=Cluster{j}(6,i)-EnergyReceiveOrder-EnergyPerSend-cost(Cluster{j}(3,mc),Cluster{j}(3,i));
               X(6,Cluster{j}(3,i))=Cluster{j}(6,i);
          end
      end
      %更新簇成员
      temp=[];
      p=1;
      for i=1:1:C_size(j)
            if Cluster{j}(6,i)<0 %已经死亡
              C_size(j)=C_size(j)-1;
              if FirstRound==-1 %第一轮死亡出现
                  FirstRound=round;
              end
              X(4,Cluster{j}(3,i))=0;
            else
              temp(:,p)=Cluster{j}(:,i);
              p=p+1;
            end
      end

      Cluster{j}=[];Cluster{j}=temp;
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
   OrgGAF_D(round)=livecount;
   round=round+1;

end
% figure(1);
% hold on;
% for i=1:1:N
%   if X(4,i)==0 % 死亡
%       plot(X(1,i),X(2,i),'k .','MarkerSize',3);
%   else
%       plot(X(1,i),X(2,i),'k o','MarkerSize',3);
%   end
% end
% plot(X(1,N+1),X(2,N+1),'k *');
% text(X(1,N+1),X(2,N+1),'  Base');%6代表汇聚节点
% set(gca,'xlim',[0,maprange]);
% set(gca,'ylim',[0,maprange]);
% xlabel('X-coordinate','FontSize',10);
% ylabel('Y-coordinate','FontSize',10);
% title('Hot-spot Issue in LEACH-C','FontSize',10);
% hold off;
AliveNodesPerRound=OrgGAF_D;
save('GAF_LiveNode.mat','AliveNodesPerRound');
save('GAF_Energy.mat','EnergyPerRound');
LastRound=round-1;
FirstRound
FirstClusterDie
LastRound
lifetime



