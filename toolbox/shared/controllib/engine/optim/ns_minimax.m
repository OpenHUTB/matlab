function LOG=ns_minimax(SYSDATA,SPECDATA,tInfo,x0,OPTS,LOG)
















    MAXITER=OPTS.MaxIter;
    RELTOL=OPTS.TolObj;
    TARGET=max(1e-12,OPTS.Target);
    MAXWINDOW=OPTS.MaxWindow;
    TraceOptions=OPTS.Trace;


    hHist=zeros(MAXITER,1);


    for ct=1:numel(SPECDATA)
        if SPECDATA(ct).Soft
            SPECDATA(ct).fWeight=OPTS.alpha;
        end
    end


    [SPECDATA,SYSDATA,tInfo]=evalObjective(x0,Inf,SPECDATA,SYSDATA,tInfo,OPTS);
    WeightedObj=[SPECDATA.fWeight].*[SPECDATA.fObj];
    hObj=max(WeightedObj);
    ScaledSC=hObj*[SPECDATA.fStab;SPECDATA.fRad];
    [hSpec,tInfo.SpecEvalOrder]=sort(max([WeightedObj;ScaledSC]),'descend');
    h=hSpec(1);
    Soft=[SPECDATA.Soft];


    x=x0;
    xMin=tInfo.pMin(tInfo.iFree);
    xMax=tInfo.pMax(tInfo.iFree);
    iter=0;
    if h>TARGET
        hHist(1)=h;
        OPTS.wStab=hObj;


        [hB,J,g]=getBundle(x0,hObj,SPECDATA,SYSDATA,tInfo,OPTS);


        np=length(x);
        tau=min(1,10*sqrt(hObj)/norm(x0));
        RH=tau*eye(np);
        perm=1:np;
        d=zeros(np,1);
        LSWoptions=struct('c1',1e-4,'c2',0.9,...
        'Delta',0,'Target',-Inf,'Display',0,'SMax',Inf);
        FUNW=@localEvalFG;



        LastScalingObj=hObj;
        LastScalingIter=0;
        TargetReached=false;
        while iter<MAXITER&&~OPTS.StopFcn()
            iter=iter+1;


            xScale=1+abs(x);
            dmax=min(xScale,xMax-x);
            dmin=-min(xScale,x-xMin);
            d(perm,1)=getSearchDir(J(perm,:),hB,RH,true,dmin(perm),dmax(perm),TraceOptions);


            aux=max((xMax-x)./d,(xMin-x)./d);
            aux(d==0)=Inf;
            LSWoptions.SMax=min(aux);
            LSWoptions.Delta=2*OPTS.TolHinf*h;
            dirderiv=g'*d;
            [stp,SPECDATA,SYSDATA,tInfo]=linesearchWF(FUNW,h,x,d,dirderiv,SPECDATA,...
            SYSDATA,tInfo,OPTS,LSWoptions);


            xNew=x+stp*d;
            WeightedObj=[SPECDATA.fWeight].*[SPECDATA.fObj];
            hObjNew=max(WeightedObj);
            if TraceOptions.Verbosity>2


                TraceOptions.DisplayFcn(getString(message('Control:tuning:systune17',...
                iter,sprintf('%.4g',hObjNew),sprintf('%.3g',100*max(0,1-hObjNew/hObj)))))
            end



            if stp==0
                break
            end






            [hB,J,gNew]=getBundle(xNew,hObjNew,SPECDATA,SYSDATA,tInfo,OPTS);
            [RH,perm]=updateLocalModel(RH,perm,x,xNew,g,gNew,TraceOptions);







            if hObjNew<OPTS.wStab/2||rem(iter,5)==0
                OPTS.wStab=hObjNew;
            end


            ScaledSC=OPTS.wStab*[SPECDATA.fStab;SPECDATA.fRad];
            [hSpec,tInfo.SpecMap(4,:)]=sort(max([WeightedObj;ScaledSC]),'descend');
            x=xNew;h=hSpec(1);g=gNew;hObj=hObjNew;


            if~TargetReached

                if hObj<=TARGET
                    if OPTS.TargetRefine



                        TargetReached=true;
                        MAXITER=iter+5;
                    else

                        break
                    end
                end


                hHist(iter)=h;
                hWindow=max(10,MAXWINDOW-floor(iter/20));
                if iter>hWindow&&hHist(iter-hWindow)<(1+RELTOL)*h

                    break
                end
            end






            if iter==1||iter>LastScalingIter+25||hObj<LastScalingObj/5
                SYSDATA=updateScaling(SPECDATA,SYSDATA,tInfo);
                LastScalingObj=hObj;
                LastScalingIter=iter;
            end

        end
    end


    fObj=[SPECDATA.fObj];
    LOG.F=max([-Inf,fObj(Soft)]);
    LOG.G=max([-Inf,fObj(~Soft)]);
    LOG.X=x;
    LOG.DS=tInfo.DR;
    LOG.Iter=LOG.Iter+iter;
    LOG.FinalData=SPECDATA;

    iC=[SPECDATA.Config];

    fStabCL=max([-Inf,SPECDATA(iC>0).fStab]);
    fStabB=max([-Inf,SPECDATA(iC==0).fStab]);

    LOG.MinDecay=OPTS.MinDecay*(2-[fStabCL,fStabB]);

    LOG.Fstab=OPTS.MinDecay*(max(fStabCL,fStabB)-1);


    isep=[0,find(diff([SPECDATA.Goal])>0),numel(SPECDATA)];
    ngoal=numel(isep)-1;
    fSpec=zeros(1,ngoal);
    isSoft=false(1,ngoal);
    for ct=1:ngoal
        fSpec(ct)=max(fObj(isep(ct)+1:isep(ct+1)));
        isSoft(ct)=SPECDATA(isep(ct)+1).Soft;
    end
    LOG.fSoft=fSpec(isSoft);
    LOG.gHard=fSpec(~isSoft);

    Flags=zeros(0,2);
    for ct=1:numel(SPECDATA)
        if~isempty(SPECDATA(ct).Flag)
            Flags=cat(1,Flags,[SPECDATA(ct).Goal,SPECDATA(ct).Flag]);
        end
    end
    LOG.Diagnostics=Flags;

end



function[h,g,SPECDATA,SYSDATA,tInfo]=localEvalFG(x,hTest,SPECDATA,SYSDATA,tInfo,OPTS)




    wStab=OPTS.wStab;
    [SPECDATA,SYSDATA,tInfo]=evalObjective(x,hTest,SPECDATA,SYSDATA,tInfo,OPTS);
    [hObj,iObj]=max([SPECDATA.fWeight].*[SPECDATA.fObj]);
    [hStab,iStab]=max(wStab*[SPECDATA.fStab]);
    [hRad,iRad]=max(wStab*[SPECDATA.fRad]);
    [h,iAct]=max([hObj,hStab,hRad]);
    g=[];
    if h<hTest

        Ts=tInfo.Ts;
        if iAct==1

            FD=SPECDATA(iObj);
            iM=FD.Model;
            iC=FD.Config;
            fWeight=FD.fWeight;

            if FD.Type==0

                alpha=FD.Spectral.MinDecay;
                zeta=FD.Spectral.MinDamping;
                rho=FD.Spectral.MaxFrequency;
                if iC==0

                    Focus=[0,Inf];
                else

                    SD=SYSDATA(iM,iC);
                    Focus=FD.Band;
                end
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
                    aux=[realE/(-alpha),(realE./absE)/(-zeta)];
                    fSpec=[NSOptUtil.SpectralPenalty(aux),absE/rho];
                end
                fSpec(~inFocus,:)=-Inf;
                [~,jmax]=max(max(fSpec,[],1));
                [~,imax]=max(fSpec(:,jmax));

                switch jmax
                case 1
                    if alpha<0
                        tau=-1/alpha;
                    else
                        tau=NSOptUtil.gradSpectralPenalty(aux(imax,1))/(-alpha);
                    end
                case 2
                    lambda=E(imax);
                    tau=(NSOptUtil.gradSpectralPenalty(aux(imax,2))/absE(imax)^3/zeta)*...
                    (complex(0,imag(lambda))*lambda);
                case 3
                    tau=(E(imax)./absE(imax))/rho;
                end
                if Ts>0
                    tau=tau/conj(Ts*E0(imax));
                end
                if iC==0
                    g=NSOptUtil.gradBlockDynamics(tInfo,iM,x,U(:,imax),V(:,imax),fWeight*tau);
                else
                    g=NSOptUtil.gradLoopDynamics(SD,tInfo,x,FD.xPerf,U(:,imax),V(:,imax),fWeight*tau);
                end
            else

                SD=SYSDATA(iM,iC);
                switch FD.Type
                case{1,3}

                    g=fWeight*NSOptUtil.gradHinfPerf(FD,SD,tInfo,x,FD.PeakFreq);
                case 2

                    g=fWeight*NSOptUtil.gradH2Perf(FD,SD,tInfo,x);
                    if any(isnan(g))


                        h=Inf;g=[];
                    end
                case 4

                    g=fWeight*NSOptUtil.gradRelIndex(FD,SD,tInfo,OPTS.Rmax,x,FD.PeakFreq);
                end
            end
        elseif iAct==2

            FD=SPECDATA(iStab);
            iC=FD.Config;
            if iC==0

                E=FD.E;
            else
                SD=SYSDATA(FD.Model,iC);
                if FD.Type==4

                    E=FD.E;
                else

                    E=SD.Es;
                end
            end
            mu=wStab/OPTS.MinDecay;
            if Ts>0

                [zmax,imax]=max(abs(E));
                tau=(mu/zmax^2)*E(imax);
            else
                [~,imax]=max(real(E));
                tau=mu;
            end
            if iC==0
                g=NSOptUtil.gradBlockDynamics(tInfo,FD.Model,x,FD.U(:,imax),FD.V(:,imax),tau);
            elseif FD.Type==4
                g=NSOptUtil.gradSectorDynamics(SD,tInfo,x,FD,FD.U(:,imax),FD.V(:,imax),tau);
            else
                g=NSOptUtil.gradLoopDynamics(SD,tInfo,x,SD.xStab,SD.Us(:,imax),SD.Vs(:,imax),tau);
            end
        else


            FD=SPECDATA(iRad);
            iC=FD.Config;
            SD=SYSDATA(FD.Model,iC);
            if FD.Type==4

                E=FD.E;
            else

                E=SD.Es;
            end
            [zmax,imax]=max(abs(E));
            tau=(wStab/OPTS.MaxRadius/zmax)*E(imax);
            if FD.Type==4
                g=NSOptUtil.gradSectorDynamics(SD,tInfo,x,FD,FD.U(:,imax),FD.V(:,imax),tau);
            else
                g=NSOptUtil.gradLoopDynamics(SD,tInfo,x,SD.xStab,SD.Us(:,imax),SD.Vs(:,imax),tau);
            end
        end
        g(isnan(g))=0;
    end
end

