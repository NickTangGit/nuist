clc;
clear;
%% ����һ������
% N=100;%���������ڵ������
EnergyThreshold=1000000;%�����ܶ���ţ�10^(-6) J

load TestDataforPear.mat X
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


r=50;%ͨ�Ű뾶
Nc=4;%�صĸ���
flag=[25 25 25 25];



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
           cost2(i,j)=EnergyPerTrans*((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2);% ������չΪ�������ĺ���
           Distance(i,j)=((X(2,j)-X(2,i))^2+(X(1,j)-X(1,i))^2)^0.5;
        else
           cost2(i,j)=0;
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
%4.��ͷͨ��GBP �����ݴ��͵�sink

%����ÿ�ֵĺ��ܣ�
%1.��ͷ�ڵ㣺Pʣ��=Pԭ��-����sink�������-����������Ա��Ŀ*����BitsPerTime����������Ϣ����-����BitsPerTime����������Ϣ����-����BitsPerTime����������Ϣ����һ���ĺ���
%2.�Ǵ�ͷ�ڵ㣺Pʣ��=Pԭ��-����sink�������-����BitsPerTime����������Ϣ����-����BitsPerTime����������Ϣ����ͷ�ĺ���
C_size=flag; %��¼ÿ���صĽڵ����
round=1;%��һ��
FirstRound=-1;
FirstClusterDieRound=-1;
[m_Num,~]=max(C_size);%m_Num ��ʾC_size���سߴ磩���������صĳߴ磬ֻҪ����ߴ����0����˵����Ⱥ�廹����š�
RestX=X(1:5,:);
RestE=X(6,1:N);
livecount=N;%>0,��˵����Ⱥ�廹����š�
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
    %�ó�ÿ���صĴ�ͷ(ѡ��ʣ����������),���Ҽ���ÿ���ؽڵ��ʣ������
    C_num=1;%���ڼ�¼��ͷ�ڴ�ͷ����ı��
    CH=[];%��մ�ͷ
    ECC=[0,0];
    for j=1:1:Nc %��ÿ���ؽ��в���
      if C_size(j)<=0
          continue;
      end
      [~,mc]=max(Cluster{j}(6,:));%ѡ��ʣ������������Ϊ��ͷ
      CH(:,C_num)=[Cluster{j}(:,mc);mc;j];% CH�ĵ�7�м�¼�˸ô�ͷ�ڸô��е�λ�ã���8�м�¼�˴غ�
      C_num=C_num+1;
      %ÿ����ͷҪ���ܴ������нڵ����Ϣ����Ҫ���ѵ�����Ϊ��(C_size(j)-1)*EnergyPerReceive���������м�ȥ��
      Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1)*EnergyPerReceive;
    %  Cluster{j}(6,mc)=Cluster{j}(6,mc)-EnergyReceiveOrder-(C_size(j)-1)*EnergyPerReceive-5*EnergyPerSend-5*cost2(N+1,Cluster{j}(3,mc));
  
          
      
      ECC(1)=ECC(1)+(C_size(j)-1)*EnergyPerReceive;%ͳ����
      ECC(2)=ECC(2)+5*EnergyPerSend+5*cost2(N+1,Cluster{j}(3,mc));
      if Cluster{j}(6,mc)<=0 %��ֹ����GBP_Trainʱ����ֵΪ������
          Cluster{j}(6,mc)=10;
      end
      index2=FindID(RestX(3,:),Cluster{j}(3,mc));
      if index2==0
         disp('1');
      end
      RestE(index2)=Cluster{j}(6,mc);
      % ���·Ǵ�ͷ��ʣ������
      for i=1:1:C_size(j)
          if i~=mc %��Ǵ�ͷ��ʣ������
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
%              if FirstRound==-1 %��һ����������
%               FirstRound=round;
%              end
%             
%         end
%     end
        
%% ���´�ͷ��ʣ������
    [~,C_num]=size(CH);
    ID_Index=[];
    ID_Index=CH(3,1:C_num);
    RestX(5,:)=0;  % ��շ���λ ÿ�ֿ�ʼʱ�����ٿ��Ա�֤�����Щ�ڵ㶼�ǻ��ŵģ���Ϊֻ�л��ŲŻᱻ������

    for i=1:1:C_num %ÿһ�֣������е�ǰ�����š��Ĵ�ͷ���в�ѯ
       [~,CurSize]=size(RestX);
       k=FindID(RestX(3,1:CurSize-1),ID_Index(i));%�ڵ�ǰʣ���RestX�ڵ�ID����(3,1:NN)��Ѱ��IDΪID_Index(i)�Ľڵ㣬
       if  k==0%�ýڵ��Ѿ��������ڵ�ǰʣ���RestX�Ҳ����ˣ�ֱ����һ��
           continue;
       end
       %��һ��RestE
       [Wmax,~]=max(RestE);
       TempWW=RestE/Wmax;
 
       RestX(1,CurSize)=PositionSet(1);
       RestX(2,CurSize)=PositionSet(2);   
       [~,Next,C,~,RestX,RestE]=GBP_Train(RestX,RestE,TempWW,Eelec,Eamp,5*BitsPerTime,OrderLength,NoteIDLength,k,DisBasetoCenter);
      
       
    end
  
      %���´س�Ա
     for j=1:1:Nc%��ÿ���ؽ��в���      
      temp=[];
      p=1;
      IsClusterLive=0;
      tmp_Cs=C_size(j);
      for i=1:1:tmp_Cs
           index=FindID(RestX(3,:),Cluster{j}(3,i));%�ҳ��ýڵ�����RestX
           if index==0
             Cluster{j}(6,i)=0;%�Ѿ�����
             C_size(j)=C_size(j)-1;
             index2=FindID(X(3,:),Cluster{j}(3,i));%�ҳ��ڵ�����X��ID��
             if index2==0
                disp('cao');
             end
             X(4,index2)=0;
              
                   if FirstRound==-1 %��һ����������
                     
                      FirstRound=round;
                   end
           else
             Cluster{j}(6,i)=RestE(index);
             temp(:,p)=Cluster{j}(:,i);
             p=p+1;
             IsClusterLive=1;%ֻҪ�нڵ���ţ��ؾͻ��š�
           end
      end
      if IsClusterLive==0  && FirstClusterDieRound==-1; %�д�����
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


