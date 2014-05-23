function flag= test(a,b,c,d)
flag=0;
arr=[];
arr(1)=a;
arr(2)=b;
arr(3)=c;
arr(4)=d;
e=0;
for i=1:1:4
    for j=2:1:4
       if arr(j)<arr(j-1)
           e=arr(j-1);
           arr(j-1)=arr(j);
           arr(j)=e;
       end
    end
end
for i=2:1:4
    if arr(i)==arr(i-1)
        flag=1;
        break;
    end
end
for i=1:1:4
    if arr(i)==1
        flag=1;
        break;
    end
end

           

    
end