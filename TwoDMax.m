function [m,n,v]= TwoDMax(array)
%m ����
%n ����
%v ֵ
[mv,mcol]=max(array);
[mvv,mvcol]=max(mv);
v=mvv;
m=mcol(mvcol);
n=mvcol;
end