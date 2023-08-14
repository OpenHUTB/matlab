function[uppermu,DG0,DGS]=mussvSmoothDG(CLg,blk,FullDG)






    fixedBlkIdx=[];
    index=rctutil.mkBlkData(blk,fixedBlkIdx);
    index.allreal.realidx=rctutil.mkBlkData(index.allreal.realblk,[]);
    index.allcomp.compidx=rctutil.mkBlkData(index.allcomp.compblk,[]);
    index.problemType='musyn';


    dtol=1e-3;
    DGLMI=rctutil.DGLMIsys(index,fixedBlkIdx,FullDG);
    DGLMI.dtol=dtol;
    DGLMI.LMIopt=[1e-2,0,1/dtol,5,1];
    index.allDGlmi=DGLMI;


    [M,w,Ts]=frdata(CLg);
    [Mr,Mc,Nw]=size(M);



    uppermu=zeros(Nw,1);
    Dr0=zeros(Mr,Mr,Nw);
    Dc0=zeros(Mc,Mc,Nw);
    Gcr0=zeros(Mc,Mr,Nw);
    DGinit=struct('Dr',eye(Mr),'Dc',eye(Mc),'Gcr',zeros(Mc,Mr),'ub',[]);
    for ct=1:Nw


        [dMd,Dr_os,Dci_os]=osbal(M(:,:,ct),index,'d');
        Dr_os=diag(Dr_os);
        Dc_os=1./diag(Dci_os);


        DGinit.ub=1.01*norm(dMd);
        [ub,Dr,~,Dc,Gcr]=mulmiub(dMd,index,DGinit);
        ub=max(ub,1e-3);


        normM=norm(M(:,:,ct));
        if ub<normM
            uppermu(ct)=ub;


            tau=max(sqrt(3*dtol./diag(Dr))./Dr_os);
            Dr_os=tau*Dr_os;Dc_os=tau*Dc_os;
            Dr0(:,:,ct)=Dr.*(Dr_os*Dr_os');
            Dc0(:,:,ct)=Dc.*(Dc_os*Dc_os');
            Gcr0(:,:,ct)=Gcr.*(Dc_os*Dr_os');
        else
            uppermu(ct)=normM;
            Dr0(:,:,ct)=eye(Mr);
            Dc0(:,:,ct)=eye(Mc);
        end
    end
    ubmax=max(uppermu);













    ub=max(1.01*ubmax^0.01*uppermu.^0.99,0.01*ubmax);
    index.allDGlmi.LMIopt=[1e-2,0,-1,5,1];
    DrS=zeros(Mr,Mr,Nw);
    DcS=zeros(Mc,Mc,Nw);
    GcrS=zeros(Mc,Mr,Nw);


    [DrS(:,:,1),DcS(:,:,1),GcrS(:,:,1)]=mulmiubMinGap(M(:,:,1),index,...
    ub(1),Dr0(:,:,1),Gcr0(:,:,1),dtol*eye(Mr),dtol*eye(Mc),zeros(Mc,Mr));


    for ct=2:Nw
        [DrS(:,:,ct),DcS(:,:,ct),GcrS(:,:,ct)]=mulmiubMinGap(M(:,:,ct),index,...
        ub(ct),Dr0(:,:,ct),Gcr0(:,:,ct),DrS(:,:,ct-1),DcS(:,:,ct-1),GcrS(:,:,ct-1));
    end







    ifit=[];
    Dr=DrS(:,:,1);Dc=DcS(:,:,1);Gcr=GcrS(:,:,1);
    for ct=2:Nw
        if localDGgap(Dr,Dc,Gcr,DrS(:,:,ct),GcrS(:,:,ct))>0.1
            ifit=[ifit,ct];break %#ok<*AGROW>
        end
    end
    Dr=DrS(:,:,Nw);Dc=DcS(:,:,Nw);Gcr=GcrS(:,:,Nw);
    for ct=Nw-1:-1:1
        if localDGgap(Dr,Dc,Gcr,DrS(:,:,ct),GcrS(:,:,ct))>0.1
            ifit=[ifit,ct];break
        end
    end
    if isempty(ifit)
        if Ts==0
            imin=find(w>1e-3,1,'first');
            imax=find(w<1e3,1,'last');
        else
            nf=pi/abs(Ts);
            imin=find(w>1e-6*nf,1,'first');
            imax=find(w<nf,1,'last');
        end
    else



        fmin=w(min(ifit));
        fmax=w(max(ifit));
        if Ts==0
            fc=sqrt(fmin*fmax);
            fmin=max(1e-4*fc,min(1e-2*fc,fmin/10));
            fmax=min(1e4*fc,max(1e2*fc,10*fmax));
        else
            nf=pi/abs(Ts);
            fmin=max(fmin/10,1e-6*nf);
            fmax=max(10*fmax,1e4*fmin);
        end
        imin=find(w>fmin,1,'first');
        imax=find(w<fmax,1,'last');
    end


    for ct=1:Nw
        d=DrS(Mr,Mr,ct);
        DrS(:,:,ct)=DrS(:,:,ct)/d;
        DcS(:,:,ct)=DcS(:,:,ct)/d;
        GcrS(:,:,ct)=GcrS(:,:,ct)/d;
    end
    DG0=struct('Dr',Dr0,'Dc',Dc0,'Gcr',Gcr0,'ub',uppermu);
    DGS=struct('Frequency',w,'Dr',DrS,'Dc',DcS,'Gcr',GcrS,'ub',ub,'FitRange',[imin,imax]);


















    function gap=localDGgap(Dr,Dc,Gcr,Dr2,Gcr2)
        dr=sqrt(diag(Dr));dc=sqrt(diag(Dc));
        gapD=abs(dr.\(Dr-Dr2)./dr.');
        gapG=abs(dc.\(Gcr-Gcr2)./dr.');
        gap=max([gapD(:);gapG(:)]);

