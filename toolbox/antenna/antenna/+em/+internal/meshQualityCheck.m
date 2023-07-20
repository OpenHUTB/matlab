function[q,qmin,qavg]=meshQualityCheck(p,t)
    a=sqrt((p(t(:,2),1)-p(t(:,1),1)).^2+(p(t(:,2),2)-p(t(:,1),2)).^2);
    b=sqrt((p(t(:,3),1)-p(t(:,2),1)).^2+(p(t(:,3),2)-p(t(:,2),2)).^2);
    c=sqrt((p(t(:,1),1)-p(t(:,3),1)).^2+(p(t(:,1),2)-p(t(:,3),2)).^2);

    q=(b+c-a).*(c+a-b).*(a+b-c)./(a.*b.*c);
    qmin=min(q);
    qavg=sum(q)/(size(t,1));

end
