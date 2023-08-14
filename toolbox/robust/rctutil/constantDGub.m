function[ub,DG,DGInfo]=constantDGub(Gg,index4mu,V)








    userMuOpt=V.userMuOpt;
    osborneCondNum=V.osborneCondNumber;
    UseLMI=any(userMuOpt=='a');
    if~all(isfinite(Gg(:)))

        ub=Inf;DG=[];DGInfo=[];return
    end

    nAD=size(Gg,3);
    if nAD>1
        [~,Dr_os,Dci_os]=osbal(sum(Gg,3)/nAD,index4mu,'f',osborneCondNum);
        for i=nAD:-1:1
            dMd(:,:,i)=Dr_os*Gg(:,:,i)*Dci_os;
        end
    else
        [dMd,Dr_os,Dci_os]=osbal(Gg,index4mu,'f',osborneCondNum);
    end
    Dc_os=inv(Dci_os);


    aux=sum(abs(dMd),3)/nAD;
    scale=max(aux(:));
    if scale==0
        scale=1;
    end
    iVC=index4mu.FVidx.VaryCols;
    dMd(:,iVC,:)=dMd(:,iVC,:)/scale;



    if UseLMI&&strcmp(index4mu.problemType,'wcgain')

        DGinit=[];
    else
        DGinit=mkDGinit(dMd,index4mu,userMuOpt);
        if isinf(DGinit.ub)

            ub=Inf;DG=[];DGInfo=[];return
        end
    end


    if UseLMI
        ubTarget=0.5*V.gUBmax/scale;
        [ub,Dr,DcF,DcV,Gcr]=mulmiub(dMd,index4mu,DGinit,ubTarget);





    else
        [ub,Dr,DcF,DcV,Gcr]=mudescentub(dMd,index4mu,DGinit);
    end
    DGInfo=struct('Dr',Dr,'DcF',DcF,'DcV',DcV,'Gcr',Gcr,...
    'Dr_os',Dr_os,'Dc_os',Dc_os,'Dci_os',Dci_os,'scale',scale);
    Gcr=Dc_os'*Gcr*Dr_os;
    Gcr(iVC,:)=scale*Gcr(iVC,:);
    Dr=Dr_os'*Dr*Dr_os;Dr=(Dr+Dr')/2;
    DcF=Dc_os'*DcF*Dc_os;DcF=(DcF+DcF')/2;
    DcV=Dc_os'*DcV*Dc_os;DcV=(DcV+DcV')/2;
    DG=struct('Dr',Dr,'DcF',DcF,'DcV',DcV,'Gcr',Gcr);
    ub=scale*ub;









