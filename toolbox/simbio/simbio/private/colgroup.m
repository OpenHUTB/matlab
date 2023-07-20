function gout=colgroup(S)














    [m,n]=size(S);
    [i,j]=find(S);
    T=sparse(i,j,1,m,n);


    if any(sum(T,2)==n)
        gout=(1:n)';
        return
    end

    TT=tril(T'*T);


    g=zeros(n,1);
    groupnum=0;
    J=(1:n)';
    while~isempty(J)
        groupnum=groupnum+1;
        g(J(1))=groupnum;
        col=full(TT(:,J(1)));
        for k=J'
            if col(k)==0
                col=col+TT(:,k);
                g(k)=groupnum;
            end
        end
        J=find(g==0);
    end


    p=colamd(T);
    p=p(n:-1:1);
    T=T(:,p);
    TT=tril(T'*T);


    g2=zeros(n,1);
    groupnum2=0;
    J=(1:n)';
    while~isempty(J)
        groupnum2=groupnum2+1;
        g2(J(1))=groupnum2;
        col=full(TT(:,J(1)));
        for k=J'
            if col(k)==0
                col=col+TT(:,k);
                g2(k)=groupnum2;
            end
        end
        J=find(g2==0);
    end


    if groupnum<=groupnum2
        gout=g;
    else
        q(p)=1:n;
        gout=g2(q);
    end
