clc;
clear;
%% ����һ������
% N=100;%���������ڵ������
EnergyThreshold=1000000;%�����ܶ���ţ�10^(-6) J

load TestDataforLEACH_C.mat X
[~,N]=size(X);
maprange=100;%��ͼ�ߴ�
PositionSet=[0,0];
X(1,N+1)=PositionSet(1);%5���������ڵ������  ���һ��sink=[10;10];%��۽ڵ������
X(2,N+1)=PositionSet(2);

%    X(3,i) X������Ϊÿ���ڵ�Ĺ̶���ʶ�������ֱ�ʾ
%    X(4,i) X������ ��ʾÿ���ڵ��Ƿ�������1�������ţ�0������������ʼ��������
%    X(5,i) X������ ��ʾÿ���ڵ��Ƿ񱻷��ʣ�1�������ʹ���0����Ϊ���ʣ���ʼ����δ����
%    X(6,i) EnergyThreshold;%X��6�У� ��ʾÿ���ڵ��ʣ������

DisBasetoCenter=((PositionSet(1)-50)^2+(PositionSet(2)-50)^2)^0.5;

[pcount,~]=size(PositionSet);


r=50;%ͨ�Ű뾶
Nc=4;%�صĸ���
Cluster=cell(1,4);%Ԫ�����飬��¼4����

for i=1:1:100
  [csize,~]=size(Cluster{X(3,i)});
   Cluster{X(3,i)}(csize+1) ==i;
end


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
% Order�����    Receive ID������Ͷ���ڵ�ID��   Relative ID�����ID�ţ�
% 01 00              XX                                   YY                  01��ʾ��������Ϊ��ѯ�����ѯ�ֶ�Ϊ��00���¶ȣ�������վ�Ѳ�ѯ��Ϣ����XX�����Ҹ����������ݷ��͸�YY���ɣ�
% 01 01              XX                                   YY                  01��ʾ��������Ϊ��ѯ�����ѯ�ֶ�Ϊ��01��ʪ�ȣ�
% 01 XX              XX                                   YY                  01��ʾ��������Ϊ��ѯ�����ѯ�ֶ�Ϊ��XX��������
% 02 00              AA                                   BB                  02��ʾ��������Ϊ������һ�����Ҳ��������AA����һ��ΪBB����ôһ��AA��������Ҫ���ͣ�������ݷ��͸�BB������ѯ�ֶ�Ϊ��00���¶ȣ�������

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
lifetime=0;

DeliverC=1;

while m_Num>0

    EnergyPerRound(round)=((EnergyThreshold*100)-sum(X(6,1:N)))/(EnergyThreshold*100);
    %�ó�ÿ���صĴ�ͷ(ѡ��ʣ����������),���Ҽ���ÿ���ؽڵ��ʣ������
    CH_ID=[0,0,0,0];
    ECC=[0,0];
    
   for j=1:1:4 %��ÿ���ؽ��в���
       
      for k=1:1:4 %��ÿ���ؽ��в���
         [mcs,ncs]=size(Cluster{k});
         if(ncs==0)
             continue;
         else
         [mv,mc]=max(Cluster{k}(6,:));
          CH_ID(k)=mc;%��¼���Ǵ������ڵ����꣬���ǽڵ�ID
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
      
      % ���´�ͷʣ������
      if(DeliverC==1)
          
      if j==1  % ����ǵ�һ����
          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1+3)*EnergyPerReceive-20*EnergyPerSend-20*cost(N+1,Cluster{j}(3,mc));
      end
      if j==2  % ����ǵ�2����
          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1+0)*EnergyPerReceive-PackageNum*EnergyPerSend-PackageNum*cost(Cluster{1}(3,CH_ID(1)),Cluster{j}(3,mc));
      end
      if j==3  % ����ǵ�3����
          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1+0)*EnergyPerReceive-PackageNum*EnergyPerSend-PackageNum*cost(Cluster{1}(3,CH_ID(1)),Cluster{j}(3,mc));
      end
      if j==4  % ����ǵ�4����
          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1+0)*EnergyPerReceive-PackageNum*EnergyPerSend-PackageNum*cost(Cluster{1}(3,CH_ID(1)),Cluster{j}(3,mc));
      end
      end
      
   
          
      
         X(6,Cluster{j}(3,mc))=Cluster{j}(6,mc);
      for i=1:1:C_size(j)
          if i~=mc %��Ǵ�ͷ��ʣ������
              Cluster{j}(6,i)=Cluster{j}(6,i)-EnergyReceiveOrder-EnergyPerSend-cost(Cluster{j}(3,mc),Cluster{j}(3,i));
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
%text(X(1,N+1),X(2,N+1),'Sink');%6������۽ڵ�
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
%   if X(4,i)==0 % ����
%       plot(X(1,i),X(2,i),'k .','MarkerSize',3);
%   else
%       plot(X(1,i),X(2,i),'k o','MarkerSize',3);
%   end
% end
% plot(X(1,N+1),X(2,N+1),'k *');
% text(X(1,N+1),X(2,N+1),'  Base');%6������۽ڵ�
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


