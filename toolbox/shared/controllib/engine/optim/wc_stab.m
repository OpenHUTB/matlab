function[wcFstab,wcx]=wc_stab(SYSDATA,SPECDATA,tInfo,x0,OPTS)




    wcFstab=-Inf;
    wcx=[];




    [SPECDATA1,SPECDATA2]=NSOptUtil.uniqueMC(SPECDATA);
    SPECDATA=[SPECDATA1;SPECDATA2];
    nspec=numel(SPECDATA);
    if nspec==0

        return
    end
    tInfo.SpecEvalOrder=1:nspec;


    np=size(x0,1);
    x0=[x0,-1+2*rand(np,9)];


    xMin=-ones(np,1);
    xMax=ones(np,1);
    FUN=@(x)localEvalFG(x,SPECDATA,SYSDATA,tInfo,OPTS);
    wcFstab=-Inf;
    for ct=1:size(x0,2)
        [x,f]=tr_solver(x0(:,ct),FUN,xMin,xMax,OPTS);
        Fstab=-f;

        if Fstab>wcFstab
            wcx=x;
            wcFstab=Fstab;
        end
        if wcFstab>0

            return
        end
    end



    function[f,df]=localEvalFG(x,SPECDATA,SYSDATA,tInfo,OPTS)

        [SPECDATA,SYSDATA]=evalSpectralConstr(x,Inf,SPECDATA,SYSDATA,tInfo,OPTS);
        [f,iMax]=max([SPECDATA.fStab]);
        f=-f;

        if isinf(f)
            df=[];
        else
            FD=SPECDATA(iMax);
            E=FD.E;
            iC=FD.Config;

            if tInfo.Ts>0
                [zmag,ix]=max(abs(E));
                tau=E(ix)/(zmag^2);
            else
                [~,ix]=max(real(E));
                tau=1;
            end
            SD=SYSDATA(FD.Model,iC);
            if FD.Type==4
                df=-NSOptUtil.gradSectorDynamics(SD,tInfo,x,FD,FD.U(:,ix),FD.V(:,ix),tau);
            else
                df=-NSOptUtil.gradLoopDynamics(SD,tInfo,x,SD.xStab,FD.U(:,ix),FD.V(:,ix),tau);
            end
            df(isnan(df))=0;
        end
















