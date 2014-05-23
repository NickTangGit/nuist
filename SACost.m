function re= SACost(a,b,c,d,arr)
[m,n]=size(arr);
re=0;
for i=1:1:n
        ttt(1)=arr(i,a);
        ttt(2)=arr(i,b);
        ttt(3)=arr(i,c);
        ttt(4)=arr(i,d);
        [vv,ll]=min(ttt);
        re=re+vv;
end
       

           
