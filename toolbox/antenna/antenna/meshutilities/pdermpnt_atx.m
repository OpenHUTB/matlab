function[p,e,t]=pdermpnt_atx(p,e,t)






    i=t(1:3,:);i=i(:);
    j=zeros(1,size(p,2));
    j(i)=ones(size(i));
    k=cumsum(j);

    j=find(j);
    p=p(:,j);
    e(1:2,:)=reshape(k(e(1:2,:)),2,size(e,2));
    t(1:3,:)=reshape(k(t(1:3,:)),3,size(t,2));

