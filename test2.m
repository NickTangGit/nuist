function flag= test2(a,b,c,d,arr)
flag=0;
[m,n]=size(arr);
tempa(1)=a;
tempa(2)=b;
tempa(3)=c;
tempa(4)=d;

for i=1:1:4
    for j=2:1:4
       if tempa(j)<tempa(j-1)
           e=tempa(j-1);
           tempa(j-1)=tempa(j);
           tempa(j)=e;
       end
    end
end


for i=1:1:m
    
    
      
      if arr(i,1)==tempa(1) && arr(i,2)==tempa(2)  && arr(i,3)==tempa(3)  && arr(i,4)==tempa(4)  
        flag=1;
        break;
       end
end