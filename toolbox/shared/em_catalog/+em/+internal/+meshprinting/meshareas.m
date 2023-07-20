function A=meshareas(P,t)









    d12=P(t(:,2),:)-P(t(:,1),:);
    d13=P(t(:,3),:)-P(t(:,1),:);
    temp=cross(d12,d13,2);
    A=0.5*sqrt(dot(temp,temp,2));
end


