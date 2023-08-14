function[circumcenters,R]=meshcircumcenters(P,t)






    a=sqrt(sum((P(t(:,2),:)-P(t(:,1),:)).^2,2));
    b=sqrt(sum((P(t(:,3),:)-P(t(:,1),:)).^2,2));
    c=sqrt(sum((P(t(:,3),:)-P(t(:,2),:)).^2,2));
    R=a.*b.*c./sqrt((a+b+c).*(b+c-a).*(c+a-b).*(a+b-c));

    M=size(t,1);
    circumcenters=zeros(M,3);
    for m=1:M
        B=P(t(m,3),:)-P(t(m,1),:);
        C=P(t(m,3),:)-P(t(m,2),:);
        circumcenters(m,:)=cross((c(m)^2*B-b(m)^2*C),cross(B,C))/(2*(b(m)^2*c(m)^2-dot(B,C)^2))+P(t(m,3),:);
    end
end