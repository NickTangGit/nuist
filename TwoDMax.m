function [m,n,v]= TwoDMax(array)
%m 行数
%n 列数
%v 值
[mv,mcol]=max(array);
[mvv,mvcol]=max(mv);
v=mvv;
m=mcol(mvcol);
n=mvcol;
end