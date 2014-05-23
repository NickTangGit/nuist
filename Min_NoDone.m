function [m_v,m_c]=Min_NoDone(FA,Done)
[~,N]=size(FA);
for i=1:1:N
    if Done(i)==0
        m_v=FA(i);
        m_c=i;
        break;
    end
end

for i=1:1:N
    if Done(i)==0
       if FA(i)<m_v
           m_v=FA(i);
           m_c=i;
       end
    end
end
