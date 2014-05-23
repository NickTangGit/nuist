function [FA,FNext,FC,OrgX,FRestX,FRestE] = GBP_Train(FX,FW,FWW,FEelec,FEamp,FBitsPerTime,FOrderLength,FEnergyInformationLength,QueryIndex,DisBasetoCenter)
% 功能：给定节点数组和能量数组，求一条最优路径来传输QueryIndex上的数据
% 输入
% FX-传感器节点坐标数组 5行N+1列
% FW-传感器节点原本可用能量数组 N列
% FWW-归一化后的传感器节点可用能量数组 N列
% FEelec-发送单位比特数据所需要的能量
% FEamp-每米传输1bit数据所需要的能量
% FBitsPerTime-传感器当次发送给基站的bit数目
% FOrderLength-来自基站的命令长度
% FNoteIDLength-传感器节点号的编码长度
% QueryIndex0-指定该位置的节点进行发送数据
% DisBasetoCenter-基站到网络区域中心的距离
% 输出
% FA-每个点在全局最优解下的整个系统所耗能量
% FNext-每个节点在全局最优解下的下一跳节点ID 
% FC(i) 表示第i个节点在最优评价值下的某一路径的能量消耗
% OrgX 表示 原先的输入数组FX，主要看它每个节点是否存活
% FRestX 返回新的剩余节点
% FRestE 剩余节点对应的剩余能量
[~,FN]=size(FW);%传感器的节点数
FEnergyPerTrans=FBitsPerTime*FEamp;%每次每米传输BitsPerTime个数据需要的能量。每次传输都会加上额外的能量信息16bit
FEnergyPerSend=FEelec*(FBitsPerTime);%每次发送BitsPerTime个数据需要的能量。
FEnergyPerReceive=FEelec*(FBitsPerTime);%中间节点每次接收其他节点的BitsPerTime个数据需要的能量。
FEnergyPerSendEnergyInformation=FEnergyInformationLength*FEelec;
FEnergyPerTransEnergyInformation=FEnergyInformationLength*FEamp;
FEnergyPerReceiveEnergyInformation=FEnergyInformationLength*FEelec;
FEnergyReceiveOrder=FEelec*(FOrderLength);%每次的命令由三个字段组成，其可能情况如下（支持扩展）：

OrgX=FX;
% Order（命令）    Receive ID（命令发送对象节点ID）   Relative ID（相关ID号）
% 01 00              XX                                   YY                  01表示该条命令为查询命令，查询字段为：00（温度），（基站把查询消息告诉XX，并且告诉他把数据发送给YY即可）
% 01 01              XX                                   YY                  01表示该条命令为查询命令，查询字段为：01（湿度）
% 01 XX              XX                                   YY                  01表示该条命令为查询命令，查询字段为：XX（其他）
% 02 00              AA                                   BB                  02表示该条命令为设置下一跳命令（也就是设置AA的下一跳为BB，那么一旦AA有数据需要发送，则把数据发送给BB），查询字段为：00（温度），并且

%% 计算每两个节点之间的传输信息的花费，我们用距离的平方来计算。
% cost(i,j) 表示第j个节点传输BitsPerTime量的数据信息到i，所花费的传输能量。
for i=1:1:FN+1
    for j=1:1:FN+1 % 节点j到节点i的距离
        if i~=j
           tempdistance=((FX(2,j)-FX(2,i))^2+(FX(1,j)-FX(1,i))^2);
           cost(i,j)=FEnergyPerTrans*tempdistance;% 可以拓展为能量消耗函数
         %  Distance(i,j)=((FX(2,j)-FX(2,i))^2+(FX(1,j)-FX(1,i))^2)^0.5;
           EnergyInformationCost(i,j)=FEnergyPerTransEnergyInformation*tempdistance;   % 额外的剩余能量信息（ID+剩余能量）
        else
           cost(i,j)=0;
           EnergyInformationCost(i,j)=0;
         %  Distance(i,j)=0;
        end
    end
end


% Distance(N+1,:)
%% 下面是一个开放的统筹模型，用于评价路径的综合性函数,注意这里的函数不同于W的评价函数
% 我们采用的公式 (Accessment)A=Min[（传输耗费能量cost+每次发送特定数据的能量+每次接收命令耗费的能量）*(1/W)]=Min[cost/W]。 这里的W=PA。Min(1/W)即Max(W)
% 其含义是：使得cost最小，而且PA最大的路径。
% 这样的平衡了两大难点：均衡使用能量，最小的代价总体花费。

Min0_Or_Max1=0;% 0代表求最小FA，1代表求最大FA,2代表求最大 最小PA
Coiefficient=atan(DisBasetoCenter);

%% 初始化评价数组
% FA(i) 表示第i个节点到汇聚节点在最优评价函数参考下的最优函数值， 初始化时，表示每个节点按照直传的方式执行时的评价函数值
% FC(i) 表示第i个节点在最优评价值下的某一路径的能量消耗
% CC(i) FC数组的归一化数组
% FNext(i) 表示 第i个节点在最优评价函数下取得最优值时的吓一跳节点ID。
% A Node AN(i,j) 表示第j个传感器节点到第i个传感器节点的评价值
% C Node CN(i,j) 表示第j个传感器节点到第i个传感器节点最优评价值下的能量消耗
% CCN CN的归一化数组
for i=1:1:FN
      FC(i)=FEnergyPerSend+FEnergyPerSendEnergyInformation+cost(FN+1,i)+EnergyInformationCost(FN+1,j);%求出每个点直传到汇聚节点下的能耗=发射能量+命令接收能量+传输能量
      AdditionalC(i)= FEnergyPerReceiveEnergyInformation+FEnergyPerSendEnergyInformation+EnergyInformationCost(FN+1,j);% 假如这个节点是某个节点的第N跳，那么每份 用于传输额外节点的剩余能量信息（ID+PA）的耗能为AdditionalC(i)
end
for i=1:1:FN
    for j=1:1:FN
       if i==j
           CN(i,j)=0;
       else
           ECN(i,j)=FEnergyPerSendEnergyInformation+FEnergyPerReceiveEnergyInformation+EnergyInformationCost(i,j);%单份额外信息所耗能量
           CN(i,j)=FEnergyPerSend+FEnergyPerReceive+cost(i,j)+ECN(i,j); %求出每两个点之间直传下的额外能耗=发射数据能量+接收数据能量（与发射一样）+传输能量+节点命令接收能量
           
           %注意,其中发射点所耗的能量为“发射数据能量+传输能量+节点命令接收能量（FEnergyPerSend+cost(i,j)+FEnergyReceiveOrder）”
           %接收点所耗的能量为“接收数据能量（FEnergyPerSend）”
           %在使用CN时，要注意每个节点的能量损失情况
       end
    end
end
%归一化C数组和CN数组:去两个数组中的最大值为1，然后其他的值除以该值
[maxC,~]=max(FC);
[maxCN,~]=max(CN);
[maxv,~]=max(maxCN);
[maxv,~]=max([maxC,maxv]);

CC=FC/maxv;
CCN=CN/maxv;
% 取归一化后的最大最小值
[minCC,~]=min(CC);
[minCCN,~]=min(CCN);
[minv,~]=min(minCCN);
[minv,~]=min([minCC,minCCN]);
mid_value=(minv+1)/2;


%影响因子u，可以控制距离对评价值的影响。u属于[0,1]
u=1;
for i=1:1:FN
      FA(i)=u*CC(i)/(FWW(i));
  %   FA(i)=(u*(CC(i)-mid_value)+mid_value)/FWW(i);%     1. 评价函数=归一化的所耗能量/归一化的剩余能量, 缩小距离带来的能量差值  
  %  FA(i)=CC(i);%           2. 评价函数=归一化的所耗能量
 %   FA(i)=FW(i);%           3. 评价函数=剩余能量，意味着 最大能量剩余路径的将被选择。 最大PA
end
for i=1:1:FN
    for j=1:1:FN
     AN(i,j)=u*CCN(i,j)/(FWW(i));
   %  AN(i,j)=100000000;
  %   AN(i,j)=(u*(CCN(i,j)-mid_value)+mid_value)/FWW(j); %  1. 每个节点往下一跳移动时，所增加的额外耗能四部分组成：j节点发送数据所耗能量+i节点接收数据所耗能量+传输所耗能量+j节点接受命令所耗能量。
  %   AN(i,j)=CCN(i,j);           %  2. 只考虑能量消耗，找一条传输到汇聚节点，且所使用总体能量最小的那条路径。
 %   能量消耗的基础上可以考虑其他的因素，比如最大最小PA路由算法。在临时取得的数组中，求得一条链中最小PA最大的路由
 %   AN(i,j)=FW(i)+FW(j);       %  3. 只考虑剩余能量
    end
end

%% Dijkstra Algorithm
% Done(i) 用于记录第i个节点是否运算完毕 若=1则已经完毕，若=0则未处理
% 在这个阶段忽略了中间节点（非源节点）额外发送的自身节点信息数据
% （在实现过程中我使用了空间换时间的策略，如果是时间换空间，那么不需要tem数组，直接更新A(i)即可）
Done=zeros(1,FN);%初始化为0
FNext=zeros(0,FN);% 初始化为汇聚节点的ID
for initial=1:1:FN
    FNext(initial)=FX(3,FN+1);
end

for r=1:1:FN %共需要求FN轮
%首先找一个在FA(i)里找一个最小值，即min(FA(i))，该节点到汇聚节点在该评价函数下肯定是最优的。这个可以通过反证法证明
  [m_value,m_col]=Min_NoDone(FA,Done);%求得temp数组的最小值，即我们所求的节点i到汇聚节点的最优评价值下的路径
  Done(m_col)=1;
  FA(m_col)=m_value;
  if FNext(m_col)~=FX(3,FN+1)%如果下一跳是汇聚节点，FC不变，否则
       NextIndex=FindID(FX(3,:),FNext(m_col));%找出下一跳ID在当前数组的位置
       FC(m_col)=FC(NextIndex)+CN(NextIndex,m_col);
  end
  % 更新FA
    for i=1:1:FN
       if Done(i)==0
          if FA(i)>(FA(m_col)+AN(m_col,i))
              FA(i)=(FA(m_col)+AN(m_col,i));
              FNext(i)=FX(3,m_col);
          end
       end
    end
end
     
        
        

%% 对第QueryIndex个节点进行查询
% C 为当前网络状态下，每个节点到汇聚节点取最优路径时，改路径下能量的总体消耗
     % 某个节点i被查询并且数据操作后，损失的能量为 C(i)-C(Next(i));所以该节点在执行操作后剩余的能量为
     % RestE(i)-(C(i)-C(Next(i))) 即RestE(i)-C(i)+C(Next(i))
     k=QueryIndex;
     while 1==1 %只要不为基站，就沿着这条路径计算其上每个节点k的剩余能量
         [~,jjj]=size(FNext);
          NextIndex=FindID(FX(3,:),FNext(k));%FNext(k)是一个真实的ID号,NextIndex记录该ID在现有FX数组中的位置
         pass_count=1;%数据传输了几个节点
         if FNext(k)~=FX(3,FN+1)%如果下一跳不是基站，那么该节点的剩余能量为：RestE(i)-CN(Next(i),i) 
            if k==QueryIndex %如果是“起源发射点”
              FW(k)=FW(k)-CN(NextIndex,k)-ECN(NextIndex,k)+FEnergyPerReceive+FEnergyPerReceiveEnergyInformation;%之所以要+FEnergyPerReceive是因为起源发射点k的CN(NextIndex,k)中包含一部分NextIndex节点的接收所耗的能量 ECN为额外信息
              pass_count=pass_count+1;
            else
              FW(k)=FW(k)-CN(NextIndex,k)-pass_count*ECN(NextIndex,k);%这里不需要加了，因为这些中间传输节点，拥有了两个过程：接收数据，发送数据; 数据经过pass_count次传输，需要携带更多的额外能量信息。
              pass_count=pass_count+1;
            end
         else% 下一跳是基站,
             if k==QueryIndex %如果是“起源发射点”那该节点的剩余能量，为： 原始能量-直传所耗能量(无接收数据耗能)
                 FW(k)=FW(k)-FC(k);
             else %如果是“中间传输节点”那该节点的剩余能量，为： 原始能量-直传所耗能量-接收数据耗能（从上一跳节点接收的数据）
                 FW(k)=FW(k)-FC(k)+FEnergyPerReceive-(pass_count-1)*AdditionalC(k);%节点剩余能量额外信息直传所耗费能量
             end
            break;%如果是基站，跳出循环
         end
         k=FindID(FX(3,1:jjj),FNext(k));
     end
     ppp=1;
     tempX=[];
     tempW=[];
     for j=1:1:FN
       if FW(j)>10 %没有干涸，则继续使用，已经干涸则从网络中排除  
           tempX(:,ppp)=FX(:,j);
           tempW(ppp)=FW(j);
           OrgX(4,j)=1;% 活着
           ppp=ppp+1;
       else
           OrgX(4,j)=0;% 死亡
       end
     end
     %把汇聚节点的坐标添加到tempX后
     tempX(:,ppp)=FX(:,FN+1);
     FRestX=[];%释放原来的数组
     FRestE=[];%释放原来的数组
     FRestX=tempX;
     FRestE=tempW;


% 
% for i=1:1:N
%      if Next(i)==N+1
%           RestE(i)=W(i)-C(i);
%      else
%         RestE(i)=W(i)-CN(Next(i),i);
%      end
% end