function[incenters,r]=meshincenters(P,t)







    a=sqrt(sum((P(t(:,2),:)-P(t(:,1),:)).^2,2));
    b=sqrt(sum((P(t(:,3),:)-P(t(:,1),:)).^2,2));
    c=sqrt(sum((P(t(:,3),:)-P(t(:,2),:)).^2,2));
    r=0.5*sqrt((b+c-a).*(c+a-b).*(a+b-c)./(a+b+c));

    M=size(t,1);
    incenters=zeros(M,3);
    for m=1:M
        incenters(m,:)=(c(m)*P(t(m,1),:)+b(m)*P(t(m,2),:)+a(m)*P(t(m,3),:))/(a(m)+b(m)+c(m));
    end
end