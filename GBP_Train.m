function [FA,FNext,FC,OrgX,FRestX,FRestE] = GBP_Train(FX,FW,FWW,FEelec,FEamp,FBitsPerTime,FOrderLength,FEnergyInformationLength,QueryIndex,DisBasetoCenter)
% ���ܣ������ڵ�������������飬��һ������·��������QueryIndex�ϵ�����
% ����
% FX-�������ڵ��������� 5��N+1��
% FW-�������ڵ�ԭ�������������� N��
% FWW-��һ����Ĵ������ڵ������������ N��
% FEelec-���͵�λ������������Ҫ������
% FEamp-ÿ�״���1bit��������Ҫ������
% FBitsPerTime-���������η��͸���վ��bit��Ŀ
% FOrderLength-���Ի�վ�������
% FNoteIDLength-�������ڵ�ŵı��볤��
% QueryIndex0-ָ����λ�õĽڵ���з�������
% DisBasetoCenter-��վ�������������ĵľ���
% ���
% FA-ÿ������ȫ�����Ž��µ�����ϵͳ��������
% FNext-ÿ���ڵ���ȫ�����Ž��µ���һ���ڵ�ID 
% FC(i) ��ʾ��i���ڵ�����������ֵ�µ�ĳһ·������������
% OrgX ��ʾ ԭ�ȵ���������FX����Ҫ����ÿ���ڵ��Ƿ���
% FRestX �����µ�ʣ��ڵ�
% FRestE ʣ��ڵ��Ӧ��ʣ������
[~,FN]=size(FW);%�������Ľڵ���
FEnergyPerTrans=FBitsPerTime*FEamp;%ÿ��ÿ�״���BitsPerTime��������Ҫ��������ÿ�δ��䶼����϶����������Ϣ16bit
FEnergyPerSend=FEelec*(FBitsPerTime);%ÿ�η���BitsPerTime��������Ҫ��������
FEnergyPerReceive=FEelec*(FBitsPerTime);%�м�ڵ�ÿ�ν��������ڵ��BitsPerTime��������Ҫ��������
FEnergyPerSendEnergyInformation=FEnergyInformationLength*FEelec;
FEnergyPerTransEnergyInformation=FEnergyInformationLength*FEamp;
FEnergyPerReceiveEnergyInformation=FEnergyInformationLength*FEelec;
FEnergyReceiveOrder=FEelec*(FOrderLength);%ÿ�ε������������ֶ���ɣ������������£�֧����չ����

OrgX=FX;
% Order�����    Receive ID������Ͷ���ڵ�ID��   Relative ID�����ID�ţ�
% 01 00              XX                                   YY                  01��ʾ��������Ϊ��ѯ�����ѯ�ֶ�Ϊ��00���¶ȣ�������վ�Ѳ�ѯ��Ϣ����XX�����Ҹ����������ݷ��͸�YY���ɣ�
% 01 01              XX                                   YY                  01��ʾ��������Ϊ��ѯ�����ѯ�ֶ�Ϊ��01��ʪ�ȣ�
% 01 XX              XX                                   YY                  01��ʾ��������Ϊ��ѯ�����ѯ�ֶ�Ϊ��XX��������
% 02 00              AA                                   BB                  02��ʾ��������Ϊ������һ�����Ҳ��������AA����һ��ΪBB����ôһ��AA��������Ҫ���ͣ�������ݷ��͸�BB������ѯ�ֶ�Ϊ��00���¶ȣ�������

%% ����ÿ�����ڵ�֮��Ĵ�����Ϣ�Ļ��ѣ������þ����ƽ�������㡣
% cost(i,j) ��ʾ��j���ڵ㴫��BitsPerTime����������Ϣ��i�������ѵĴ���������
for i=1:1:FN+1
    for j=1:1:FN+1 % �ڵ�j���ڵ�i�ľ���
        if i~=j
           tempdistance=((FX(2,j)-FX(2,i))^2+(FX(1,j)-FX(1,i))^2);
           cost(i,j)=FEnergyPerTrans*tempdistance;% ������չΪ�������ĺ���
         %  Distance(i,j)=((FX(2,j)-FX(2,i))^2+(FX(1,j)-FX(1,i))^2)^0.5;
           EnergyInformationCost(i,j)=FEnergyPerTransEnergyInformation*tempdistance;   % �����ʣ��������Ϣ��ID+ʣ��������
        else
           cost(i,j)=0;
           EnergyInformationCost(i,j)=0;
         %  Distance(i,j)=0;
        end
    end
end


% Distance(N+1,:)
%% ������һ�����ŵ�ͳ��ģ�ͣ���������·�����ۺ��Ժ���,ע������ĺ�����ͬ��W�����ۺ���
% ���ǲ��õĹ�ʽ (Accessment)A=Min[������ķ�����cost+ÿ�η����ض����ݵ�����+ÿ�ν�������ķѵ�������*(1/W)]=Min[cost/W]�� �����W=PA��Min(1/W)��Max(W)
% �京���ǣ�ʹ��cost��С������PA����·����
% ������ƽ���������ѵ㣺����ʹ����������С�Ĵ������廨�ѡ�

Min0_Or_Max1=0;% 0��������СFA��1���������FA,2��������� ��СPA
Coiefficient=atan(DisBasetoCenter);

%% ��ʼ����������
% FA(i) ��ʾ��i���ڵ㵽��۽ڵ����������ۺ����ο��µ����ź���ֵ�� ��ʼ��ʱ����ʾÿ���ڵ㰴��ֱ���ķ�ʽִ��ʱ�����ۺ���ֵ
% FC(i) ��ʾ��i���ڵ�����������ֵ�µ�ĳһ·������������
% CC(i) FC����Ĺ�һ������
% FNext(i) ��ʾ ��i���ڵ����������ۺ�����ȡ������ֵʱ����һ���ڵ�ID��
% A Node AN(i,j) ��ʾ��j���������ڵ㵽��i���������ڵ������ֵ
% C Node CN(i,j) ��ʾ��j���������ڵ㵽��i���������ڵ���������ֵ�µ���������
% CCN CN�Ĺ�һ������
for i=1:1:FN
      FC(i)=FEnergyPerSend+FEnergyPerSendEnergyInformation+cost(FN+1,i)+EnergyInformationCost(FN+1,j);%���ÿ����ֱ������۽ڵ��µ��ܺ�=��������+�����������+��������
      AdditionalC(i)= FEnergyPerReceiveEnergyInformation+FEnergyPerSendEnergyInformation+EnergyInformationCost(FN+1,j);% ��������ڵ���ĳ���ڵ�ĵ�N������ôÿ�� ���ڴ������ڵ��ʣ��������Ϣ��ID+PA���ĺ���ΪAdditionalC(i)
end
for i=1:1:FN
    for j=1:1:FN
       if i==j
           CN(i,j)=0;
       else
           ECN(i,j)=FEnergyPerSendEnergyInformation+FEnergyPerReceiveEnergyInformation+EnergyInformationCost(i,j);%���ݶ�����Ϣ��������
           CN(i,j)=FEnergyPerSend+FEnergyPerReceive+cost(i,j)+ECN(i,j); %���ÿ������֮��ֱ���µĶ����ܺ�=������������+���������������뷢��һ����+��������+�ڵ������������
           
           %ע��,���з�������ĵ�����Ϊ��������������+��������+�ڵ��������������FEnergyPerSend+cost(i,j)+FEnergyReceiveOrder����
           %���յ����ĵ�����Ϊ����������������FEnergyPerSend����
           %��ʹ��CNʱ��Ҫע��ÿ���ڵ��������ʧ���
       end
    end
end
%��һ��C�����CN����:ȥ���������е����ֵΪ1��Ȼ��������ֵ���Ը�ֵ
[maxC,~]=max(FC);
[maxCN,~]=max(CN);
[maxv,~]=max(maxCN);
[maxv,~]=max([maxC,maxv]);

CC=FC/maxv;
CCN=CN/maxv;
% ȡ��һ����������Сֵ
[minCC,~]=min(CC);
[minCCN,~]=min(CCN);
[minv,~]=min(minCCN);
[minv,~]=min([minCC,minCCN]);
mid_value=(minv+1)/2;


%Ӱ������u�����Կ��ƾ��������ֵ��Ӱ�졣u����[0,1]
u=1;
for i=1:1:FN
      FA(i)=u*CC(i)/(FWW(i));
  %   FA(i)=(u*(CC(i)-mid_value)+mid_value)/FWW(i);%     1. ���ۺ���=��һ������������/��һ����ʣ������, ��С���������������ֵ  
  %  FA(i)=CC(i);%           2. ���ۺ���=��һ������������
 %   FA(i)=FW(i);%           3. ���ۺ���=ʣ����������ζ�� �������ʣ��·���Ľ���ѡ�� ���PA
end
for i=1:1:FN
    for j=1:1:FN
     AN(i,j)=u*CCN(i,j)/(FWW(i));
   %  AN(i,j)=100000000;
  %   AN(i,j)=(u*(CCN(i,j)-mid_value)+mid_value)/FWW(j); %  1. ÿ���ڵ�����һ���ƶ�ʱ�������ӵĶ�������Ĳ�����ɣ�j�ڵ㷢��������������+i�ڵ����������������+������������+j�ڵ������������������
  %   AN(i,j)=CCN(i,j);           %  2. ֻ�����������ģ���һ�����䵽��۽ڵ㣬����ʹ������������С������·����
 %   �������ĵĻ����Ͽ��Կ������������أ����������СPA·���㷨������ʱȡ�õ������У����һ��������СPA����·��
 %   AN(i,j)=FW(i)+FW(j);       %  3. ֻ����ʣ������
    end
end

%% Dijkstra Algorithm
% Done(i) ���ڼ�¼��i���ڵ��Ƿ�������� ��=1���Ѿ���ϣ���=0��δ����
% ������׶κ������м�ڵ㣨��Դ�ڵ㣩���ⷢ�͵�����ڵ���Ϣ����
% ����ʵ�ֹ�������ʹ���˿ռ任ʱ��Ĳ��ԣ������ʱ�任�ռ䣬��ô����Ҫtem���飬ֱ�Ӹ���A(i)���ɣ�
Done=zeros(1,FN);%��ʼ��Ϊ0
FNext=zeros(0,FN);% ��ʼ��Ϊ��۽ڵ��ID
for initial=1:1:FN
    FNext(initial)=FX(3,FN+1);
end

for r=1:1:FN %����Ҫ��FN��
%������һ����FA(i)����һ����Сֵ����min(FA(i))���ýڵ㵽��۽ڵ��ڸ����ۺ����¿϶������ŵġ��������ͨ����֤��֤��
  [m_value,m_col]=Min_NoDone(FA,Done);%���temp�������Сֵ������������Ľڵ�i����۽ڵ����������ֵ�µ�·��
  Done(m_col)=1;
  FA(m_col)=m_value;
  if FNext(m_col)~=FX(3,FN+1)%�����һ���ǻ�۽ڵ㣬FC���䣬����
       NextIndex=FindID(FX(3,:),FNext(m_col));%�ҳ���һ��ID�ڵ�ǰ�����λ��
       FC(m_col)=FC(NextIndex)+CN(NextIndex,m_col);
  end
  % ����FA
    for i=1:1:FN
       if Done(i)==0
          if FA(i)>(FA(m_col)+AN(m_col,i))
              FA(i)=(FA(m_col)+AN(m_col,i));
              FNext(i)=FX(3,m_col);
          end
       end
    end
end
     
        
        

%% �Ե�QueryIndex���ڵ���в�ѯ
% C Ϊ��ǰ����״̬�£�ÿ���ڵ㵽��۽ڵ�ȡ����·��ʱ����·������������������
     % ĳ���ڵ�i����ѯ�������ݲ�������ʧ������Ϊ C(i)-C(Next(i));���Ըýڵ���ִ�в�����ʣ�������Ϊ
     % RestE(i)-(C(i)-C(Next(i))) ��RestE(i)-C(i)+C(Next(i))
     k=QueryIndex;
     while 1==1 %ֻҪ��Ϊ��վ������������·����������ÿ���ڵ�k��ʣ������
         [~,jjj]=size(FNext);
          NextIndex=FindID(FX(3,:),FNext(k));%FNext(k)��һ����ʵ��ID��,NextIndex��¼��ID������FX�����е�λ��
         pass_count=1;%���ݴ����˼����ڵ�
         if FNext(k)~=FX(3,FN+1)%�����һ�����ǻ�վ����ô�ýڵ��ʣ������Ϊ��RestE(i)-CN(Next(i),i) 
            if k==QueryIndex %����ǡ���Դ����㡱
              FW(k)=FW(k)-CN(NextIndex,k)-ECN(NextIndex,k)+FEnergyPerReceive+FEnergyPerReceiveEnergyInformation;%֮����Ҫ+FEnergyPerReceive����Ϊ��Դ�����k��CN(NextIndex,k)�а���һ����NextIndex�ڵ�Ľ������ĵ����� ECNΪ������Ϣ
              pass_count=pass_count+1;
            else
              FW(k)=FW(k)-CN(NextIndex,k)-pass_count*ECN(NextIndex,k);%���ﲻ��Ҫ���ˣ���Ϊ��Щ�м䴫��ڵ㣬ӵ�����������̣��������ݣ���������; ���ݾ���pass_count�δ��䣬��ҪЯ������Ķ���������Ϣ��
              pass_count=pass_count+1;
            end
         else% ��һ���ǻ�վ,
             if k==QueryIndex %����ǡ���Դ����㡱�Ǹýڵ��ʣ��������Ϊ�� ԭʼ����-ֱ����������(�޽������ݺ���)
                 FW(k)=FW(k)-FC(k);
             else %����ǡ��м䴫��ڵ㡱�Ǹýڵ��ʣ��������Ϊ�� ԭʼ����-ֱ����������-�������ݺ��ܣ�����һ���ڵ���յ����ݣ�
                 FW(k)=FW(k)-FC(k)+FEnergyPerReceive-(pass_count-1)*AdditionalC(k);%�ڵ�ʣ������������Ϣֱ�����ķ�����
             end
            break;%����ǻ�վ������ѭ��
         end
         k=FindID(FX(3,1:jjj),FNext(k));
     end
     ppp=1;
     tempX=[];
     tempW=[];
     for j=1:1:FN
       if FW(j)>10 %û�иɺԣ������ʹ�ã��Ѿ��ɺ�����������ų�  
           tempX(:,ppp)=FX(:,j);
           tempW(ppp)=FW(j);
           OrgX(4,j)=1;% ����
           ppp=ppp+1;
       else
           OrgX(4,j)=0;% ����
       end
     end
     %�ѻ�۽ڵ��������ӵ�tempX��
     tempX(:,ppp)=FX(:,FN+1);
     FRestX=[];%�ͷ�ԭ��������
     FRestE=[];%�ͷ�ԭ��������
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