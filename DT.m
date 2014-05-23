clc;
clear;
%% ����һ������
% N=100;%���������ڵ������
EnergyThreshold=1000000;%�����ܶ���ţ�10^(-6) J
% SensorDiameter=100;%�������ڵ�ֲ��뾶 100M
% X=50+SensorDiameter*rand(2,N);%
% load X from local data
load TestData.mat X
%X=X(:,5:10);
[~,N]=size(X);
maprange=100;%��ͼ�ߴ�
X(:,N+1)=[50;50];%5���������ڵ������  ���һ��sink=[10;10];%��۽ڵ������
for i=1:1:N+1
    X(3,i)=i;%X������Ϊÿ���ڵ�Ĺ̶���ʶ�������ֱ�ʾ
    X(4,i)=1;%X������ ��ʾÿ���ڵ��Ƿ�������1������ţ�0������������ʼ��������
    X(5,i)=0;%X������ ��ʾÿ���ڵ��Ƿ񱻷��ʣ�1������ʹ���0����Ϊ���ʣ���ʼ����δ����
    X(6,i)=EnergyThreshold;%X��6�У� ��ʾÿ���ڵ��ʣ������
end

% 
% figure(1);
% hold on;
% %plot(X(1,1:N),X(2,1:N),'k o','markersize',3);
% for i=1:1:N
%     %text(X(1,i),X(2,i)',strcat(num2str(i),',  ',num2str(W(i))));%��ʾ�����ܶ�
%    % text(X(1,i),X(2,i)',num2str(i));
% end
% plot(X(1,N+1),X(2,N+1),'b *');
% text(X(1,N+1),X(2,N+1),'Sink');%6�����۽ڵ�
% set(gca,'xlim',[0,maprange]);
% set(gca,'ylim',[0,maprange]);
% hold off;

% GAF ���ִ�����
r=50;%����R=r*����5
%�������类��Ϊ4����ÿ���������һ����
flag=[1 1 1 1];
Cluster=cell(1,4);%Ԫ�����飬��¼4����
%�ֳ�4����,�����ò�ͬͼ�α��

for i=1:1:N
    if X(1,i)<=r && X(2,i)<=r % ��1
        Cluster{1}(:,flag(1))=X(:,i);
        flag(1)=flag(1)+1;
    else if X(1,i)>r && X(2,i)<=r % ��2
         Cluster{2}(:,flag(2))=X(:,i);
         flag(2)=flag(2)+1;   
        else if X(1,i)>r && X(2,i)>r % ��3
               Cluster{3}(:,flag(3))=X(:,i);
               flag(3)=flag(3)+1;   
            else % ��4
                  Cluster{4}(:,flag(4))=X(:,i);
                  flag(4)=flag(4)+1;   
             end
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
DDDD=1
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
      % ���´�ͷʣ������

          Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1+0)*EnergyPerReceive-5*EnergyPerSend-5*cost(N+1,Cluster{j}(3,mc));
          ECC(1)=ECC(1)+EnergyReceiveOrder+(C_size(j)-1+0)*EnergyPerReceive;
          ECC(2)=ECC(2)+5*EnergyPerSend+5*cost(N+1,Cluster{j}(3,mc));
   
          
      
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
    
   ECC


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
% text(X(1,N+1),X(2,N+1),'  Base');%6�����۽ڵ�
% set(gca,'xlim',[0,maprange]);
% set(gca,'ylim',[0,maprange]);
% xlabel('X-coordinate','FontSize',10);
% ylabel('Y-coordinate','FontSize',10);
% title('Hot-spot Issue in LEACH-C','FontSize',10);
% hold off;
AliveNodesPerRound=OrgGAF_D;
%save('GAF_LiveNode.mat','AliveNodesPerRound');
%save('GAF_Energy.mat','EnergyPerRound');
LastRound=round-1;
FirstRound
FirstClusterDie
LastRound
lifetime



