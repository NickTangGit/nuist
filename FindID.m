function [ID] =FindID(Arr,num)
%�ú��� ��Arr������Ѱ�ҵ�һ��ֵΪnum��Ԫ�أ��������������е�λ��
[~,n]=size(Arr);
ID=0;%�Ҳ����򷵻�0
for i=1:1:n
    if Arr(i)==num
        ID=i;
        break;
    end
end