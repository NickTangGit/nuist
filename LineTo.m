function LineTo(sx,sy,ex,ey) 
%% �ô���ͷ��ֱ���������� ���(x1,y1)-->�յ�(x2,y2) 
%% len ��ͷ�߳� 
x1=sx;
x2=ex;
y1=sy;
y2=ey;

x=[x1 x2]; 
y=[y1 y2]; 

hdl_line=line(x,y,'color',[0.5 0.5 0.5],'LineWidth',10); 

end