function [ID] =FindID(Arr,num)
%该函数 在Arr数组中寻找第一个值为num的元素，返回它在数组中的位置
[~,n]=size(Arr);
ID=0;%找不到则返回0
for i=1:1:n
    if Arr(i)==num
        ID=i;
        break;
    end
end