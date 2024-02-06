function[ub,Dr,DcF,DcV,Gcr]=mulmiub(M,index,DGinit,ubTarget)

    nin=nargin;
    if nin<3
        DGinit=[];
    end
    if nin<4||isempty(ubTarget)
        ubTarget=0;
    else
        ubTarget=min(ubTarget,1e3);
    end
    PerfLevel=1;

    [Mr,Mc,adM]=size(M);
    nreal=index.allreal.num;
    DGLMI=index.allDGlmi;
    irx=DGLMI.irx;
    icx=DGLMI.icx;
    Dr=DGLMI.Dr;
    DcF=DGLMI.DcF;
    DcV=DGLMI.DcV;
    Gcr=DGLMI.Gcr;
    e100Mat=DGLMI.e100Mat;
    ndecvars=DGLMI.numVARs;
    WCGainFlag=strcmp(index.problemType,'wcgain');
    MUSYN=strcmp(index.problemType,'musyn');

    if(isempty(DGinit)||isempty(DGinit.Dr))||WCGainFlag

        xinit=[];
        tinit=[];
    else
        Dx=DGinit.Dr(irx,irx);
        if isempty(DGLMI.Gx)
            Gx=[];
        else
            Gx=DGinit.Gcr(icx,irx);
        end

        tau=1.1*DGLMI.dtol/min(real(eig(Dx)));
        if tau>1
            Dx=Dx*tau;Gx=Gx*tau;
        end

        xinit=rctutil.DG2x(DGLMI,Dx,Gx);
        tinit=(1.01*DGinit.ub)^2;
    end

    setlmis(DGLMI.lmisysInit);

    if WCGainFlag

        Vridx=DGLMI.Vridx;
        Vcidx=DGLMI.Vcidx;
        ndecvars=ndecvars+1;
        ubsqMatreal=zeros(Mc);
        ubsqMatreal(Vcidx,Vcidx)=ndecvars*eye(numel(Vcidx));
        ubsqMat=lmivar(3,blkdiag(ubsqMatreal,ubsqMatreal));
        ubScale=max(1,2*ubTarget);
    end

    lmiterm([1,1,1,0],DGLMI.dtol);
    lmiterm([-1,1,1,DGLMI.Dx],1,1);
    nLMI=1;

    if MUSYN&&~isempty(DGLMI.Dxfd)

        nLMI=nLMI+1;
        lmiterm([-nLMI,1,1,DGLMI.Dxfd],1,0.5);
        lmiterm([-nLMI,1,2,DGLMI.Dxfo],1,1);
        lmiterm([-nLMI,2,2,DGLMI.Dxfd],1,0.5);
    end

    for i=1:adM
        Mi=M(:,:,i);
        Mreal=real(Mi);
        Mimag=imag(Mi);
        M1=[Mreal,Mimag;-Mimag,Mreal];
        if(nreal>0)
            jM2=[-Mimag,Mreal;-Mreal,-Mimag];
        end

        nLMI=nLMI+1;
        lmiterm([nLMI,1,1,Dr],M1',M1);
        if(nreal>0)
            lmiterm([nLMI,1,1,Gcr],1,jM2,'s');
        end
        if~isempty(DcF)
            lmiterm([nLMI,1,1,DcF],-PerfLevel,PerfLevel);
        end
        if WCGainFlag

            aux=M1([Vridx,Mr+Vridx],:);
            lmiterm([nLMI,1,1,0],aux'*aux);
            lmiterm([-nLMI,1,1,ubsqMat],ubScale,ubScale);
        else
            lmiterm([-nLMI,1,1,DcV],1,1);
            lmiterm([-nLMI,1,1,0],1e-100*e100Mat);
        end
    end
    nlfc=adM;

    if MUSYN&&nreal>0
        nLMI=nLMI+1;nlfc=nlfc+1;
        lmiterm([nLMI,1,2,DGLMI.Gx],1,1/DGLMI.alpha);
        lmiterm([nLMI,2,2,DGLMI.Dx],-1,1);
        lmiterm([-nLMI,1,1,DGLMI.Dx],1,1);
        lmiterm([-nLMI,2,2,0],eps*DGLMI.dtol/DGinit.ub^2);
    end

    lmisys=getlmis;

    target=max(1e-8,ubTarget^2);
    if WCGainFlag
        copt=[zeros(ndecvars-1,1);ubScale^2];

        [ubsq,xopt]=mincx(lmisys,copt,DGLMI.LMIopt,xinit,target);

    else
        [ubsq,xopt]=gevp(lmisys,nlfc,DGLMI.LMIopt,tinit,xinit,target);
    end

    if isempty(xopt)
        Dr=eye(Mr);
        Dc=eye(Mc);
        DcF=e100Mat(1:Mc,1:Mc);
        DcV=Dc-DcF;
        Gcr=zeros(Mc,Mr);
        ub=inf;
    else
        ub=sqrt(max(1e-10,ubsq));

        if nargout>1
            Dr=dec2mat(lmisys,xopt,Dr);
            Dr=complex(Dr(1:Mr,1:Mr),Dr(1:Mr,Mr+1:2*Mr));
            if isempty(DcF)
                DcF=zeros(Mc,Mc);
            else
                DcF=dec2mat(lmisys,xopt,DcF);
                DcF=complex(DcF(1:Mc,1:Mc),DcF(1:Mc,Mc+1:2*Mc));
            end
            if WCGainFlag
                Dr(Vridx,Vridx)=eye(numel(Vridx));
                DcV=zeros(Mc);
                DcV(Vcidx,Vcidx)=eye(numel(Vcidx));
            else
                DcV=dec2mat(lmisys,xopt,DcV);
                DcV=complex(DcV(1:Mc,1:Mc),DcV(1:Mc,Mc+1:2*Mc));
            end
            if(nreal>0)
                Gcr=dec2mat(lmisys,xopt,Gcr);
                Gcr=complex(Gcr(1:Mc,1:Mr),Gcr(1:Mc,Mr+1:2*Mr));

            else
                Gcr=zeros(Mc,Mr);
            end
        end
    end