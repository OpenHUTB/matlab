function[tau,DG]=maxCarveDG(M,dM,ub,index,DGInfo)










    [Mr,Mc]=size(M);
    iVC=index.FVidx.VaryCols;
    nreal=index.allreal.num;
    WCGainFlag=strcmp(index.problemType,'wcgain');


    Dr_os=DGInfo.Dr_os;
    Dc_os=DGInfo.Dc_os;
    Dci_os=DGInfo.Dci_os;
    scale=DGInfo.scale;
    M=Dr_os*M*Dci_os;
    M(:,iVC)=M(:,iVC)/scale;
    dM=Dr_os*dM*Dci_os;
    dM(:,iVC)=dM(:,iVC)/scale;
    ub=ub/scale;



    alpha=0.1*norm(M)/norm(dM);
    dM=alpha*dM;


    DGLMI=index.allDGlmi;
    lmisysInit=DGLMI.lmisysInit;
    Dr=DGLMI.Dr;
    DcF=DGLMI.DcF;
    DcV=DGLMI.DcV;
    Gcr=DGLMI.Gcr;
    irx=DGLMI.irx;
    icx=DGLMI.icx;
    setlmis(lmisysInit);


    lmiterm([1,1,1,0],DGLMI.dtol);
    lmiterm([-1,1,1,DGLMI.Dx],1,1);


    Mreal=real(M);
    Mimag=imag(M);
    M1=[Mreal,Mimag;-Mimag,Mreal];
    dMreal=real(dM);
    dMimag=imag(dM);
    dM1=[dMreal,dMimag;-dMimag,dMreal];
    if(nreal>0)
        jM2=[-Mimag,Mreal;-Mreal,-Mimag];
        jdM2=[-dMimag,dMreal;-dMreal,-dMimag];
    end
    if WCGainFlag
        Vridx=DGLMI.Vridx;
        Vcidx=DGLMI.Vcidx;
        IVr=zeros(Mr);
        IVr(Vridx,Vridx)=eye(numel(Vridx));
        IVr=blkdiag(IVr,IVr);
        IVc=zeros(Mc);
        IVc(Vcidx,Vcidx)=eye(numel(Vcidx));
        IVc=blkdiag(IVc,IVc);
        M1V=M1([Vridx,Mr+Vridx],:);
        dM1V=dM1([Vridx,Mr+Vridx],:);
    end

    for nLMI=2:4

        if~isempty(DcF)
            lmiterm([-nLMI,1,1,DcF],1,1);
        end
        lmiterm([-nLMI,1,1,Dr],M1',-M1);
        if(nreal>0)
            lmiterm([-nLMI,1,1,Gcr],1,-jM2,'s');
        end
        if WCGainFlag

            lmiterm([-nLMI,1,1,0],ub^2*IVc-M1V'*M1V);
        else
            lmiterm([-nLMI,1,1,DcV],ub,ub);
        end
    end

    sgn=1;
    for nLMI=3:4

        lmiterm([nLMI,1,1,Dr],M1',sgn*dM1,'s');
        if(nreal>0)
            lmiterm([nLMI,1,1,Gcr],1,sgn*jdM2,'s');
        end

        lmiterm([nLMI,2,1,Dr],1,dM1);

        lmiterm([-nLMI,2,2,Dr],1,1);

        if WCGainFlag
            aux=M1V'*dM1V;
            lmiterm([nLMI,1,1,0],sgn*(aux+aux'));
            lmiterm([nLMI,2,1,0],IVr*dM1);
            lmiterm([-nLMI,2,2,0],IVr);
        end
        sgn=-sgn;
    end

    lmisys=getlmis;



    Dr_init=DGInfo.Dr;
    Gcr_init=DGInfo.Gcr;
    Dx=Dr_init(irx,irx);
    if isempty(DGLMI.Gx)
        Gx=[];
    else
        Gx=Gcr_init(icx,irx);
    end
    xinit=rctutil.DG2x(DGLMI,Dx,Gx);

    lhs1=dM'*Dr_init*dM;lhs1=(lhs1+lhs1')/2;
    lhs2=(M'*Dr_init+1i*Gcr_init)*dM;lhs2=lhs2+lhs2';
    aux=Gcr_init*M;
    rhs=ub^2*DGInfo.DcV+DGInfo.DcF-M'*Dr_init*M-1i*(aux-aux');
    rhs=(rhs+rhs')/2;
    tinit=1.1*max(max(abs(eig(lhs1+lhs2,rhs))),max(abs(eig(lhs1-lhs2,rhs))));


    nlfc=2;
    LMIopt=DGLMI.LMIopt;
    LMIopt(1)=1e-1;

    target=1;
    [topt,xopt]=gevp(lmisys,nlfc,LMIopt,tinit,xinit,target);


    tau=alpha/topt;
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
    if nreal>0
        Gcr=dec2mat(lmisys,xopt,Gcr);
        Gcr=complex(Gcr(1:Mc,1:Mr),Gcr(1:Mc,Mr+1:2*Mr));
    else
        Gcr=zeros(Mc,Mr);
    end



































    Gcr=Dc_os'*Gcr*Dr_os;
    Gcr(iVC,:)=scale*Gcr(iVC,:);
    Dr=Dr_os'*Dr*Dr_os;Dr=(Dr+Dr')/2;
    DcF=Dc_os'*DcF*Dc_os;DcF=(DcF+DcF')/2;
    DcV=Dc_os'*DcV*Dc_os;DcV=(DcV+DcV')/2;
    DG=struct('Dr',Dr,'DcF',DcF,'DcV',DcV,'Gcr',Gcr);

