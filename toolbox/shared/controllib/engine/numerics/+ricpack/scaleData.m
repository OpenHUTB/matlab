function[Sx,Sr,A,B,G,Q,R,S,E0]=scaleData(DOMAIN,A,B,G,Q,R,S,E0)




























    [n,m]=size(B);
    n2=2*n;
    if isempty(G)
        G=zeros(n);
    end


    DTFLAG=(DOMAIN=='d');
    if DTFLAG

        fgrid=pi*linspace(0,1,8);
        s=exp(complex(0,fgrid));
    else

        if isempty(E0)
            p=eig(A);
        else
            p=eig(A,E0);
        end
        wn=abs(p);
        wn=wn(wn>1e-6&wn<inf);
        if isempty(wn)
            fmin=1e-6;fmax=1e6;
        else
            fmin=0.1*min(wn);fmax=10*max(wn);
        end
        lfmin=log10(fmin);lfmax=log10(fmax);
        fgrid=logspace(lfmin,lfmax,ceil(lfmax-lfmin));
        s=complex(0,[0,fgrid,Inf]);
    end


    M=[G,A,B;A',Q,S;B',S',R];
    if isempty(E0)
        E=eye(n);
    else
        E=E0;
    end





















    Ma=abs(M);
    if DTFLAG
        Ma(1:n,n+1:n2)=Ma(1:n,n+1:n2)+abs(E);
        Ma(n+1:n2,1:n)=Ma(1:n,n+1:n2)';
    end
    Na=zeros(size(Ma));
    Z=M;
    for ct=1:numel(s)
        if isinf(s(ct))
            Zi=blkdiag(zeros(n2),ltipack.util.safeMinv(R));
        else
            aux=A-s(ct)*E;
            Z(1:n,n+1:n2)=aux;
            Z(n+1:n2,1:n)=aux';
            Zi=ltipack.util.safeMinv(Z);
        end
        if all(isfinite(Zi),'all')
            Na=Na+abs(Zi);
        end
    end





    [Sx,Sr]=hamgp(1,n,m,Ma,Na);















    if nargout>2
        Sxi=1./Sx;
        A=A.*(Sx*Sxi');
        B=B.*(Sx*Sr');
        G=G.*(Sx*Sx');
        Q=Q.*(Sxi*Sxi');
        R=R.*(Sr*Sr');
        S=S.*(Sxi*Sr');
        if~isempty(E0)
            E0=E0.*(Sx*Sxi');
        end
    end

