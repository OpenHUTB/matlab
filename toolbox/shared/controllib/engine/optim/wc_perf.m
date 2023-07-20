function[wcObj,wcx]=wc_perf(SYSDATA,SPECDATA,tInfo,x0,OPTS)






    np=size(x0,1);
    x0=[x0,-1+2*rand(np,9)];


    xMin=-ones(np,1);
    xMax=ones(np,1);
    FUN=@(x)localEvalFG(x,SPECDATA,SYSDATA,tInfo,OPTS);
    wcObj=-Inf;
    for ct=1:size(x0,2)
        [x,f]=tr_solver(x0(:,ct),FUN,xMin,xMax,OPTS);
        fObj=-f;

        if fObj>wcObj
            wcx=x;
            wcObj=fObj;
        end
        if wcObj==Inf

            return
        end
    end



    function[f,df]=localEvalFG(x,SPECDATA,SYSDATA,tInfo,OPTS)

        [SPECDATA,SYSDATA]=evalObjective(x,Inf,SPECDATA,SYSDATA,tInfo,OPTS);
        if any([SPECDATA.fStab]==Inf)
            f=-Inf;df=[];return
        end
        [f,iObj]=max([SPECDATA.fObj]);
        f=-f;

        Ts=tInfo.Ts;
        FD=SPECDATA(iObj);
        iM=FD.Model;
        iC=FD.Config;
        if FD.Type==0

            alpha=FD.Spectral.MinDecay;
            zeta=FD.Spectral.MinDamping;
            rho=FD.Spectral.MaxFrequency;
            SD=SYSDATA(iM,iC);
            Focus=FD.Band;
            E0=FD.E;U=FD.U;V=FD.V;
            if Ts>0
                E=log(E0)/Ts;
            else
                E=E0;
            end
            nE=numel(E);
            realE=real(E);
            absE=abs(E);
            inFocus=(absE>=Focus(1)&absE<=Focus(2)&isfinite(absE));


            if alpha<0
                fSpec=[realE/(-alpha),zeros(nE,1),absE/rho];
            else
                psi=[realE/(-alpha),(realE./absE)/(-zeta)];
                fSpec=[NSOptUtil.SpectralPenalty(psi),absE/rho];
            end
            fSpec(~inFocus,:)=-Inf;
            [~,jmax]=max(max(fSpec,[],1));
            [~,imax]=max(fSpec(:,jmax));

            switch jmax
            case 1
                if alpha<0
                    tau=-1/alpha;
                else
                    tau=NSOptUtil.gradSpectralPenalty(psi(imax,1))/(-alpha);
                end
            case 2
                lambda=E(imax);
                tau=(NSOptUtil.gradSpectralPenalty(psi(imax,2))/absE(imax)^3/zeta)*...
                (complex(0,imag(lambda))*lambda);
            case 3
                tau=(E(imax)./absE(imax))/rho;
            end
            if Ts>0
                tau=tau/conj(Ts*E0(imax));
            end
            df=-NSOptUtil.gradLoopDynamics(SD,tInfo,x,FD.xPerf,U(:,imax),V(:,imax),tau);
        else

            SD=SYSDATA(iM,iC);
            switch FD.Type
            case{1,3}

                df=-NSOptUtil.gradHinfPerf(FD,SD,tInfo,x,FD.PeakFreq);
            case 2

                df=-NSOptUtil.gradH2Perf(FD,SD,tInfo,x);
            case 4

                df=-NSOptUtil.gradRelIndex(FD,SD,tInfo,OPTS.Rmax,x,FD.PeakFreq);
            end
        end
        df(isnan(df))=0;