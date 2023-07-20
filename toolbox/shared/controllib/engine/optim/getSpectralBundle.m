function[fB,JB,g]=getSpectralBundle(p,f,SPECDATA,SYSDATA,tInfo,OPTS)



    f=min(0,f);
    fB=zeros(0,1);
    JB=zeros(numel(p),0);
    MINDECAY=OPTS.MinDecay;
    Ts=tInfo.Ts;

    for ct=1:numel(SPECDATA)

        FD=SPECDATA(ct);
        E=FD.E;
        iC=FD.Config;

        if Ts>0
            realE=log(abs(E));
        else
            realE=real(E);
        end

        iB=find(realE>=f-2*MINDECAY&imag(E)>=0);
        if~isempty(iB)
            fStab=realE(iB)+MINDECAY;
            if Ts>0
                tau=E(iB)./(abs(E(iB)).^2);
            else
                tau=ones(numel(iB),1);
            end
            if iC==0
                JStab=NSOptUtil.gradBlockDynamics(tInfo,FD.Model,p,FD.U(:,iB),FD.V(:,iB),tau);
            else
                SD=SYSDATA(FD.Model,iC);
                if FD.Type==4
                    JStab=NSOptUtil.gradSectorDynamics(SD,tInfo,p,FD,FD.U(:,iB),FD.V(:,iB),tau);
                else
                    JStab=NSOptUtil.gradLoopDynamics(SD,tInfo,p,SD.xStab,FD.U(:,iB),FD.V(:,iB),tau);
                end
            end


            fB=[fB;fStab];%#ok<*AGROW>
            JB=[JB,JStab];
        end
    end


    JB(isnan(JB))=0;


    [~,iAct]=max(fB);
    g=JB(:,iAct);
