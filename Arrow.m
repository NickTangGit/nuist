function Arrow(sx,sy,ex,ey) 
%% �ô���ͷ��ֱ���������� ���(x1,y1)-->�յ�(x2,y2) 
%% len ��ͷ�߳� 
x1=sx;
x2=ex;
y1=sy;
y2=ey;
cita=pi/12; %��ͷ�н�Ϊ30�� 
cos_cita=cos(cita); 
sin_cita=sin(cita); 
  
x=[x1 x2]; 
y=[y1 y2]; 
len=2;
r=len/sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)); %��ͷ�߳����߶γ��ȵı�ֵ 
hdl_line=line(x,y,'color',[0 0 0]); 
p1_x=x2; 
p1_y=y2; 
p2_x=x2+r*(cos_cita*(x1-x2)-sin_cita*(y1-y2)); 
p2_y=y2+r*(cos_cita*(y1-y2)+sin_cita*(x1-x2)); 
p3_x=x2+r*(cos_cita*(x1-x2)+sin_cita*(y1-y2)); 
p3_y=y2+r*(cos_cita*(y1-y2)-sin_cita*(x1-x2)); 
hdl_head=patch([p1_x p2_x p3_x],[p1_y p2_y p3_y],'k'); 
end