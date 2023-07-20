function[p,e,Hmin,factor]=pdemgeom_atx(g,Hmax)





    nbs=pdeigeom_atx(g);
    d=pdeigeom_atx(g,1:nbs);

    i=find(d(3,:)==0|d(4,:)==0);
    d(7,i)=d(3,i)+d(4,i);


    [x,y]=pdeigeom_atx(g,[1:nbs;1:nbs],d(1:2,:));

    small=10000*eps;
    scale=max(max(max(abs(x))),max(max(abs(y))));
    tol=small*scale;
    atol=1e-6;

    p=[x(1,1);y(1,1)];
    np=1;

    for i=1:nbs
        for j=1:2
            xy=[x(j,i);y(j,i)];
            l=find(sum(abs(p(1:2,:)-xy*ones(1,size(p,2))))<tol);
            if isempty(l)
                p=[p,[xy]];
                np=np+1;
                d(4+j,i)=np;
            else
                d(4+j,i)=l;
            end
        end
    end



    ds=0.0001*(d(2,:)-d(1,:));
    [x,y]=pdeigeom_atx(g,ones(2,1)*(1:nbs),[d(1,:);d(1,:)+ds]);
    x=reshape(x,2,nbs);
    y=reshape(y,2,nbs);
    factor=sqrt((x(2,:)-x(1,:)).^2+(y(2,:)-y(1,:)).^2)./ds;



    cur=abs(atan2(y(2,:)-y(1,:),x(2,:)-x(1,:))-...
    atan2(p(2,d(6,:))-p(2,d(5,:)),p(1,d(6,:))-p(1,d(5,:))))>atol;

    bb=[];
    ss=[];
    e=[];

    m=size(p,2)+1;

    for i=1:nbs
        if cur(i)
            n=2;
        else
            n=1;
        end
        s=linspace(d(1,i),d(2,i),n+1);
        bb=[bb;i*ones(n-1,1)];
        ss=[ss;s(2:n)'];
        e=[e,[[d(5,i),m:m+n-2]
        [m:m+n-2,d(6,i)]
        s(1:n)
        s(2:n+1)
        [i,d(3,i),d(4,i)]'*ones(1,n)]];
        m=m+n-1;
    end

    [x,y]=pdeigeom_atx(g,bb,ss);

    p=[p,[x';y']];

    Hmin=min((d(2,:)-d(1,:)).*factor);

