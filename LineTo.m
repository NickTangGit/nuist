function LineTo(sx,sy,ex,ey) 
%% 用带箭头的直线连接两点 起点(x1,y1)-->终点(x2,y2) 
%% len 箭头边长 
x1=sx;
x2=ex;
y1=sy;
y2=ey;

x=[x1 x2]; 
y=[y1 y2]; 

hdl_line=line(x,y,'color',[0.5 0.5 0.5],'LineWidth',10); 

end