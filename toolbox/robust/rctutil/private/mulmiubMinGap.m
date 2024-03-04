function[Dr,Dc,Gcr]=mulmiubMinGap(M,index,ub,Dr,Gcr,Dr0,Dc0,Gcr0)

    ubr=1.001*ub;
    H0=M'*Dr0*M-ubr^2*Dc0+2i*Gcr0*M;
    if max(eig(H0+H0'))<0
        [Dr,Dc,Gcr]=localMakeReal(Dr0,Dc0,Gcr0,M,ubr);
        return
    end

    [Mr,Mc]=size(M);
    nreal=index.allreal.num;
    DGLMI=index.allDGlmi;
    irx=DGLMI.irx;
    icx=DGLMI.icx;

    Dx=Dr(irx,irx);
    if isempty(DGLMI.Gx)
        Gx=[];
    else
        Gx=Gcr(icx,irx);
    end
    xinit=rctutil.DG2x(DGLMI,Dx,Gx);
    D0=Dr0(irx,irx);
    d0=sqrt(diag(D0));
    tDinit=1.01*norm(d0.\(Dx-D0)./d0');
    if nreal>0
        G0=Gcr0(icx,irx);
        tGinit=max(1,1.01*norm(d0.\(Gx-G0)./d0'));
    else
        tGinit=[];
    end

    setlmis(DGLMI.lmisysInit);

    lmiterm([-1,1,1,DGLMI.Dx],1,1);
    lmiterm([1,1,1,0],DGLMI.dtol);
    nLMI=1;

    Mreal=real(M);
    Mimag=imag(M);
    M1=[Mreal,Mimag;-Mimag,Mreal];
    nLMI=nLMI+1;
    lmiterm([nLMI,1,1,DGLMI.Dr],M1',M1);
    if nreal>0
        jM2=[-Mimag,Mreal;-Mreal,-Mimag];
        lmiterm([nLMI,1,1,DGLMI.Gcr],1,jM2,'s');
    end
    lmiterm([-nLMI,1,1,DGLMI.DcV],ub,ub);

    if nreal>0
        nLMI=nLMI+1;
        lmiterm([-nLMI,1,1,DGLMI.Dx],1,1);
        lmiterm([-nLMI,2,2,DGLMI.Dx],1,1);
        lmiterm([-nLMI,1,2,DGLMI.Gx],1,1/(DGLMI.alpha*ub));
    end

    if~isempty(DGLMI.Dxfd)

        nLMI=nLMI+1;
        lmiterm([-nLMI,1,1,DGLMI.Dxfd],1,0.5);
        lmiterm([-nLMI,1,2,DGLMI.Dxfo],1,1);
        lmiterm([-nLMI,2,2,DGLMI.Dxfd],1,0.5);
    end

    [tD,ndec]=lmivar(1,[1,0]);
    if DGLMI.cplxDG
        D0=[real(D0),imag(D0);-imag(D0),real(D0)];
    end
    d0=diag(diag(D0));
    nLMI=nLMI+1;
    lmiterm([-nLMI,1,1,tD],d0,1);
    lmiterm([-nLMI,2,2,tD],d0,1);
    lmiterm([-nLMI,1,2,DGLMI.Dx],1,1);
    lmiterm([-nLMI,1,2,0],-D0);

    if nreal>0
        [tG,ndec]=lmivar(1,[1,0]);
        if DGLMI.cplxDG
            G0=[real(G0),imag(G0);-imag(G0),real(G0)];
        end
        nLMI=nLMI+1;
        lmiterm([-nLMI,1,1,tG],d0,1);
        lmiterm([-nLMI,2,2,tG],d0,1);
        lmiterm([-nLMI,1,2,0],-G0);
        lmiterm([-nLMI,1,2,DGLMI.Gx],1,1);
    end

    lmisys=getlmis;
    c=zeros(ndec,1);
    c(ndec)=1;
    if nreal>0
        c(ndec-1)=1;
    end

    [topt,xopt]=mincx(lmisys,c,DGLMI.LMIopt,[xinit;tDinit;tGinit]);

    if isempty(xopt)

        Dr=Dr0;Dc=Dc0;Gcr=Gcr0;

    else
        Dr=dec2mat(lmisys,xopt,DGLMI.Dr);
        Dr=complex(Dr(1:Mr,1:Mr),Dr(1:Mr,Mr+1:2*Mr));
        Dc=dec2mat(lmisys,xopt,DGLMI.DcV);
        Dc=complex(Dc(1:Mc,1:Mc),Dc(1:Mc,Mc+1:2*Mc));
        if(nreal>0)
            Gcr=dec2mat(lmisys,xopt,DGLMI.Gcr);
            Gcr=complex(Gcr(1:Mc,1:Mr),Gcr(1:Mc,Mr+1:2*Mr));
        else
            Gcr=zeros(Mc,Mr);
        end
        [Dr,Dc,Gcr]=localMakeReal(Dr,Dc,Gcr,M,ub);
    end


    function[Dr,Dc,Gcr]=localMakeReal(Dr,Dc,Gcr,M,ub)

        Dr1=real(Dr);Dr2=imag(Dr);
        Dc1=real(Dc);Dc2=imag(Dc);
        G1=real(Gcr);G2=imag(Gcr);
        X1=M'*Dr1*M-ub^2*Dc1-2*G2*M;X1=(X1+X1')/2;
        X2=M'*Dr2*M-ub^2*Dc2+2*G1*M;X2=(X2-X2')/2;
        e=real(eig(X1,1i*X2));
        e=e(e<=0&e>-1.001);
        if isempty(e)
            alpha=0;
        else
            alpha=min(1,-max(e));
        end
        Dr=complex(Dr1,alpha*Dr2);
        Dc=complex(Dc1,alpha*Dc2);
        Gcr=complex(alpha*G1,G2);
