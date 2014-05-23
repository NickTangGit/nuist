clc;
clear;
%% ����һ������
% N=100;%���������ڵ������
EnergyThreshold=1000000;%�����ܶ���ţ�10^(-6) J
% SensorDiameter=100;%�������ڵ�ֲ��뾶 100M
% X=50+SensorDiameter*rand(2,N);%
% load X from local data
load TestDataforBCDCP.mat X
[~,N]=size(X);
maprange=100;%��ͼ�ߴ�
PositionSet=[0,0];
X(1,N+1)=PositionSet(1);%5���������ڵ������  ���һ��sink=[10;10];%��۽ڵ������
X(2,N+1)=PositionSet(2);

%    X(3,i) X������Ϊÿ���ڵ�Ĺ̶���ʶ�������ֱ�ʾ
%    X(4,i) X������ ��ʾÿ���ڵ��Ƿ�������1������ţ�0������������ʼ��������
%    X(5,i) X������ ��ʾÿ���ڵ��Ƿ񱻷��ʣ�1������ʹ���0����Ϊ���ʣ���ʼ����δ����
%    X(6,i) EnergyThreshold;%X��6�У� ��ʾÿ���ڵ��ʣ������

DisBasetoCenter=((PositionSet(1)-50)^2+(PositionSet(2)-50)^2)^0.5;

[pcount,~]=size(PositionSet);
Cluster=cell(1,4);%Ԫ�����飬��¼4����
for i=1:1:100
  [csize,~]=size(Cluster{X(3,i)});
   Cluster{X(3,i)}(csize+1) ==i;
end

r=50;%ͨ�Ű뾶
Nc=4;%�صĸ���
flag=[25 25 25 25];
Cluster=cell(1,4);%Ԫ�����飬��¼4����


[~,N]=size(X);

for i=1:1:N
    for j=1:1:N % �ڵ�j���ڵ�i�ľ���
        if i~=j
           Distance(i,j)=((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2)^0.5;
        else
           Distance(i,j)=0;
        end
    end
end

[m,~,v]=TwoDMax(Distance);


%Ѱ����m�������ǰN-K���ڵ�
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





flag=flag-1;
%% ��������
Eelec=0.05;%ÿ���ͻ��߽���1bit��Ϣ��������Ҫ�ķѵ����� 0.05 * 10^(-6) 
Eamp=0.0001;%һ�׵ľ��룬����1bit��Ϣ��������Ҫ�ķѵ����� 0.4 * 10^(-6)
BitsPerTime=2000;%��ͨ�ڵ�ÿ����Ҫ�ύ��bit��
OrderLength=26;% ������ڲ�ѯ��·�����е�����ȶ���16bit
NoteIDLength=8;% �ڵ�ŵĳ��ȣ�i��1��ʼ��N+1����ʾ��һ���ڵ�Ϊi��i=N+1ʱ��ʾ��һ��Ϊ��۽ڵ�
EnergyPerTrans=BitsPerTime*Eamp;%ÿ��ÿ�״���BitsPerTime��������Ҫ��������
EnergyPerSend=Eelec*BitsPerTime;%ÿ�η���BitsPerTime��������Ҫ��������
EnergyPerReceive=Eelec*BitsPerTime;%�м�ڵ�ÿ�ν��������ڵ��BitsPerTime��������Ҫ��������
EnergyReceiveOrder=Eelec*(OrderLength);%ÿ�ε������������ֶ���ɣ������������£�֧����չ����


%% ����ÿ�����ڵ�֮��Ĵ�����Ϣ�Ļ��ѣ������þ����ƽ�������㡣
% cost(i,j) ��ʾ��j���ڵ㴫��BitsPerTime����������Ϣ��i�������ѵĴ���������
for i=1:1:N+1
    for j=1:1:N+1 % �ڵ�j���ڵ�i�ľ���
        if i~=j
           cost(i,j)=EnergyPerTrans*((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2);% ������չΪ�������ĺ���
           Distance(i,j)=((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2)^0.5;
        else
           cost(i,j)=0;
           Distance(i,j)=0;
        end
    end
end

%ÿ�֣�
%�����ڻ�۽ڵ��Ͻ��зִغʹ�ͷѡ��ÿ��ѡ��ʣ���������Ľڵ���Ϊ��ͷ�ڵ㣩
%1.����ÿ���ڵ㶼�����һ������
%2.����ͷ֮���ÿ���ڵ㶼�ᷢ��BitsPerTime����������Ϣ���������صĴ�ͷ
%3.��ͷ�������еĴ��ڳ�Ա�����������ݡ�
%3.1 ��ͷ���������ںϣ��Ѵ��ڵ����������ںϵ���ͷ�ϵ�һ��BitsPerTime����������Ϣ���ù��̺��ܲ���
%4.��ͷͨ��ֱ�������ݴ������۽ڵ�
%����ÿ�ֵĺ��ܣ�
%1.��ͷ�ڵ㣺Pʣ��=Pԭ��-����sink�������-����������Ա��Ŀ*����BitsPerTime����������Ϣ����-����BitsPerTime����������Ϣ����-����BitsPerTime����������Ϣ��sink�ĺ���
%2.�Ǵ�ͷ�ڵ㣺Pʣ��=Pԭ��-����sink�������-����BitsPerTime����������Ϣ����-����BitsPerTime����������Ϣ����ͷ�ĺ���
C_size=flag; %��¼ÿ���صĽڵ����
round=1;%��һ��
FirstRound=-1;
[m_Num,~]=max(C_size);

FirstClusterDie=-1;
EnergyPerRound=0;
while m_Num>0

    EnergyPerRound(round)=((EnergyThreshold*100)-sum(X(6,1:N)))/(EnergyThreshold*100);
    %�ó�ÿ���صĴ�ͷ(ѡ��ʣ����������),���Ҽ���ÿ���ؽڵ��ʣ������
   % �Դ�ͷ����ʹ��MST����С����������������·��
    
   %���ѡ��һ����ͷ��Ϊͨ��
   iCH=ceil(4*rand(1));
   choseCH=0;
   ECC=[0,0];
   for j=1:1:4 %��ÿ���ؽ��в���
      [mmmc,nc]=size(Cluster{iCH});
      if(nc==0)
          for ll=1:1:4
              [mmmc,nc]=size(Cluster{ll});
              if nc~=0
                [mmmv,choseCH]=max(Cluster{ll}(6,:));
                choseCH2=ll;
              end
          end
      else
          [mmmv,choseCH]=max(Cluster{iCH}(6,:));
          choseCH2=iCH;
      end
      
      
      
      if C_size(j)<=0
          continue;
      end
      [mnnn,nnn]=size(Cluster{j});
      temppp=ceil(nnn*rand(1,1));
      mc=temppp;
      [opsdf,mc]=max(Cluster{j}(6,:));
      % ���´�ͷʣ������
      
      if j==iCH % ���ѡ��
          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1+3)*EnergyPerReceive-16*EnergyPerSend-16*cost(N+1,Cluster{j}(3,mc));
          ECC(1)=ECC(1)+EnergyReceiveOrder+(C_size(j)-1+3)*EnergyPerReceive;
           ECC(2)=ECC(2)+4*EnergyPerSend+4*cost(N+1,Cluster{j}(3,mc));
      else
          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1)*EnergyPerReceive-5*EnergyPerSend-5*cost(Cluster{choseCH2}(3,choseCH),Cluster{j}(3,mc));
           ECC(1)=ECC(1)+EnergyReceiveOrder+(C_size(j)-1+1)*EnergyPerReceive;
           ECC(2)=ECC(2)+1*EnergyPerSend+1*cost(N+1,Cluster{j}(3,mc));
      end    
      X(6,Cluster{j}(3,mc))=Cluster{j}(6,mc);
      for i=1:1:C_size(j)
          if i~=mc %��Ǵ�ͷ��ʣ������
              Cluster{j}(6,i)=Cluster{j}(6,i)-EnergyReceiveOrder-EnergyPerSend-cost(Cluster{j}(3,mc),Cluster{j}(3,i));
              ECC(1)=ECC(1)+EnergyReceiveOrder+EnergyPerSend+cost(Cluster{j}(3,mc),Cluster{j}(3,i));
               X(6,Cluster{j}(3,i))=Cluster{j}(6,i);
          end
      end
      %���´س�Ա
      temp=[];
      p=1;
      for i=1:1:C_size(j)
            if Cluster{j}(6,i)<0 %�Ѿ�����
              C_size(j)=C_size(j)-1;
              if FirstRound==-1 %��һ����������
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
% 
% if round == 2000
% figure(1);
% hold on;
% for i=1:1:N
%   if X(4,i)==0 % ����
%       plot(X(1,i),X(2,i),'k .','MarkerSize',3);
%   else
%       plot(X(1,i),X(2,i),'k o','MarkerSize',3);
%   end
% end
% plot(X(1,N+1),X(2,N+1),'k *');
% text(X(1,N+1),X(2,N+1),'  Base');%6�����۽ڵ�
% set(gca,'xlim',[0,maprange]);
% set(gca,'ylim',[0,maprange]);
% xlabel('X-coordinate','FontSize',10);
% ylabel('Y-coordinate','FontSize',10);
% title('Hot-spot Issue in BCDCP','FontSize',10);
% hold off;
% end

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
    %text(X(1,i),X(2,i)',strcat(num2str(i),',  ',num2str(W(i))));%��ʾ�����ܶ�
    if X(4,i)==0
         plot(X(1,i),X(2,i),'r x','markersize', 10);
    else
          plot(X(1,i),X(2,i),'r o');  
    end
   
  %  text(X(1,i),X(2,i)',num2str(i));
end
%plot(X(1,N+1),X(2,N+1),'b *');
%text(X(1,N+1),X(2,N+1),'Sink');%6�����۽ڵ�
set(gca,'xlim',[0,maprange]);
set(gca,'ylim',[0,maprange]);
hold off;
       
       
       
       break;
   end
   OrgGAF_D(round)=livecount;
   round=round+1;
   [m_Num,~]=max(C_size);

end
AliveNodesPerRound=OrgGAF_D;
save('BCDCP_LiveNode.mat','AliveNodesPerRound');
save('BCDCP_Energy.mat','EnergyPerRound');
LastRound=round-1;
FirstRound
FirstClusterDie
LastRound
lifetime


