function LOG=ns_perf(LOG,SYSDATA,SPECDATA,tInfo,Options)











    SOFTTARGET=max(1e-12,Options.SoftTarget);
    RELTOL=Options.SoftTol;
    TOLHINF=min(1e-6,1e-3*RELTOL);
    HiddenOptions=Options.Hidden;
    TraceOptions=HiddenOptions.Trace;

    OPTS=struct(...
    'MaxIter',Options.MaxIter,...
    'MinDecay',Options.MinDecay,...
    'MaxRadius',Options.MaxRadius,...
    'wStab',[],...
    'alpha',0,...
    'Target',0,...
    'TargetRefine',false,...
    'MaxWindow',20,...
    'TolObj',RELTOL,...
    'TolHinf',TOLHINF,...
    'Rmax',TuningGoal.ConicSector.getRmax(),...
    'Trace',TraceOptions,...
    'StopFcn',HiddenOptions.StopFcn);

    nSoft=sum([SPECDATA.Soft]);
    nHard=numel(SPECDATA)-nSoft;
    x0=LOG.X;
    StabFlags=LOG.Diagnostics;
    if nSoft==0

        OPTS.Target=1;
        LOG=ns_minimax(SYSDATA,SPECDATA,tInfo,x0,OPTS,LOG);
    elseif nHard==0

        OPTS.Target=SOFTTARGET;
        OPTS.alpha=1;
        LOG=ns_minimax(SYSDATA,SPECDATA,tInfo,x0,OPTS,LOG);
    else





        OPTS.Target=1;
        alphaMin=0;
        alphaMax=Inf;
        alpha=0.1/Options.SoftScale;
        xInit=x0;
        alphaIter=1;
        while alphaMax>(1+RELTOL)*alphaMin&&alphaIter<15



            OPTS.TargetRefine=(alpha>0);
            OPTS.alpha=alpha;
            if alphaMax<10*alphaMin

                OPTS.MaxWindow=10;
            end
            alphaLOG=ns_minimax(SYSDATA,SPECDATA,tInfo,xInit,OPTS,LOG);
            showSub(alphaLOG,Options,alpha,LOG.Iter)
            f=alphaLOG.F;g=alphaLOG.G;
            if g<=1

                LOG=alphaLOG;alphaMin=1/f;
                if f<=SOFTTARGET||alpha>(1+RELTOL)*alphaMin


                    break
                end
            else

                if alphaMin>0




                    alphaMax=alpha;
                elseif g>(1+RELTOL)*alpha*f


                    LOG=alphaLOG;break
                end
            end

            if alphaMax<alphaMin
                alphaMax=(1+10*RELTOL)*alphaMin;
            end

            if alphaMin==0

                if alphaIter>5

                    alpha=0;
                else
                    alpha=alpha/2;
                end
            elseif alphaMax==Inf

                alpha=2*alphaMin;
            else
                alpha=(alphaMin+alphaMax)/2;
            end

            xInit=alphaLOG.X;
            alphaIter=alphaIter+1;
            LOG.Iter=alphaLOG.Iter;

            if OPTS.StopFcn()
                break
            end
        end
    end
    LOG.Diagnostics=cat(1,StabFlags,LOG.Diagnostics);