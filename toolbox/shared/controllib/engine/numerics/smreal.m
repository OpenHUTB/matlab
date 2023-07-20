function[A,B,C,E,xco,eco,INFO]=smreal(A,B,C,E)











    n=size(A,1);
    if isempty(E)
        AE=spones(A)+speye(n);
    else
        AE=spones(A)+spones(E);
    end



    ec=true(n,1);xc=true(n,1);
    eo=true(n,1);xo=true(n,1);





    if~isempty(B)


        [p,q,r,c,~,rr]=dmperm([AE,any(B,2);ones(1,n+1)]);
        if rr(4)==n+2&&any(q(c(1):c(2)-1)==n+1)
            ec(p(r(2):end))=false;
            xc(q(c(2):end))=false;
        end
    end

    if~isempty(C)


        [p,q,r,c,~,rr]=dmperm([[AE;any(C,1)],ones(n+1,1)]);
        N=numel(r)-1;
        if rr(4)==n+2&&any(p(r(N):r(N+1)-1)==n+1)
            eo(p(1:r(N)-1))=false;
            xo(q(1:c(N)-1))=false;
        end
    end


    xco=xo&xc;
    eco=eo&ec;


    jx=find(xco);
    if length(jx)<n
        if isempty(E)
            A=A(jx,jx);
            B=B(jx,:);
            C=C(:,jx);
        else
            ix=find(eco);
            A=A(ix,jx);
            E=E(ix,jx);
            B=B(ix,:);
            C=C(:,jx);
        end
    end

    if nargout>6
        INFO=struct('xc',xc,'xo',xo,'ec',ec,'eo',eo);
    end