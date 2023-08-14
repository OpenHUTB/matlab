function[LOG,SYSDATA]=ns_stab(LOG,SYSDATA,SPECDATA,tInfo,Options)











    TraceOptions=Options.Hidden.Trace;
    MINDECAY=Options.MinDecay;
    OPTS=struct(...
    'MinDecay',MINDECAY,...
    'MaxIter',Options.MaxIter,...
    'Trace',TraceOptions);
    Ts=tInfo.Ts;



    [SPECDATA1,SPECDATA2,SPECDATA3]=NSOptUtil.uniqueMC(SPECDATA);




    x=LOG.X;
    SPECDATA_S=[SPECDATA1;SPECDATA2];
    nstab=numel(SPECDATA_S);
    if nstab>0
        tInfo.SpecEvalOrder=1:nstab;




        [SPECDATA_S,SYSDATA]=evalSpectralConstr(x,Inf,SPECDATA_S,SYSDATA,tInfo,OPTS);
        [fStab,tInfo.SpecEvalOrder]=sort([SPECDATA_S.fStab],'descend');
        f=fStab(1);


        xMin=tInfo.pMin(tInfo.iFree);
        xMax=tInfo.pMax(tInfo.iFree);
        gScale=1;nSkip=0;
        iter=0;
        if f>0&&f<Inf


            [fB,J,g]=getSpectralBundle(x,f,SPECDATA_S,SYSDATA,tInfo,OPTS);


            np=numel(x);
            tau=min(1,10*sqrt(f)/norm(x));
            R=tau*eye(np);
            perm=1:np;
            d=zeros(np,1);
            LSWoptions=struct('c1',1e-4,'c2',0.9,...
            'Delta',0,'Target',-Inf,'Display',0,'SMax',Inf);
            FUNW=@(a,b,c,d,e,OPTS)localEvalFG(a,b,c,d,e,OPTS);


            while iter<OPTS.MaxIter
                iter=iter+1;


                xScale=1+abs(x);
                dmax=min(xScale,xMax-x);
                dmin=-min(xScale,x-xMin);
                d(perm,1)=getSearchDir(J(perm,:),fB,R,true,dmin(perm),dmax(perm),TraceOptions);


                aux=max((xMax-x)./d,(xMin-x)./d);
                aux(d==0)=Inf;
                LSWoptions.SMax=min(aux);
                LSWoptions.Delta=1e-6*f;
                dirderiv=g'*d;
                [stp,SPECDATA_S,SYSDATA,tInfo]=linesearchWF(FUNW,f,x,d,dirderiv,SPECDATA_S,...
                SYSDATA,tInfo,OPTS,LSWoptions);


                xNew=x+stp*d;
                [fStab,newOrder]=sort([SPECDATA_S.fStab],'descend');
                fNew=fStab(1);
                if stp==0

                    break
                end


                [fB,J,gNew]=getSpectralBundle(xNew,fNew,SPECDATA_S,SYSDATA,tInfo,OPTS);
                if max(norm(g),norm(gNew))<1e6*gScale

                    [R,perm]=updateLocalModel(R,perm,x,xNew,g,gNew,TraceOptions);
                    gScale=max(gScale,abs(f-fNew)/norm(d)/stp);nSkip=0;
                else



                    nSkip=nSkip+1;
                end


                x=xNew;f=fNew;g=gNew;tInfo.SpecEvalOrder=newOrder;

                if f<=0||nSkip>3

                    break
                end
            end
        end
        SPECDATA1=SPECDATA_S(1:numel(SPECDATA1),:);


        LOG.Fstab=f;
        iC=[SPECDATA_S.Config];
        fStabCL=max([-Inf,SPECDATA_S(iC>0).fStab]);
        fStabB=max([-Inf,SPECDATA_S(iC==0).fStab]);
        LOG.MinDecay=MINDECAY-[fStabCL,fStabB];
        LOG.Iter=LOG.Iter+iter;
        LOG.FinalData=SPECDATA_S;
    else

        LOG.Fstab=-Inf;
        LOG.MinDecay=Inf(1,2);
    end
    LOG.X=x;



    nSkip=numel(SPECDATA3);
    if nSkip>0
        tInfo.SpecEvalOrder=1:nSkip;
        [SPECDATA3,SYSDATA]=evalSpectralConstr(x,Inf,SPECDATA3,SYSDATA,tInfo,OPTS);
    end


    SPECDATA=[SPECDATA1;SPECDATA3];
    Configs=zeros(0,1);Goals=zeros(0,1);
    for ct=1:numel(SPECDATA)
        FD=SPECDATA(ct);
        if FD.Config>0
            SD=SYSDATA(FD.Model,FD.Config);
            nxStab=numel(SD.xStab);
            FixedFlag=(numel(FD.E)<nxStab);
            if nxStab<numel(SD.xPerf)

                E=eig(SD.Acl);
                SYSDATA(FD.Model,FD.Config).FixedInteg.Check=...
                (Ts==0&&any(abs(E)<MINDECAY))||(Ts>0&&any(abs(E-1)<MINDECAY));
            else

                SYSDATA(FD.Model,FD.Config).FixedInteg.Check=FixedFlag;
            end
            if FixedFlag
                Configs=[Configs;FD.Config];Goals=[Goals;FD.Goal];%#ok<AGROW>
            end
        end
    end
    [~,iu]=unique(Configs,'stable');
    LOG.Diagnostics=cat(1,LOG.Diagnostics,[Goals(iu,:),ones(numel(iu),1)]);



    function[f,g,SPECDATA,SYSDATA,tInfo]=localEvalFG(x,fTest,SPECDATA,SYSDATA,tInfo,OPTS)

        [SPECDATA,SYSDATA]=evalSpectralConstr(x,fTest,SPECDATA,SYSDATA,tInfo,OPTS);
        [f,iMax]=max([SPECDATA.fStab]);


        if isinf(f)
            g=[];
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
            if iC==0
                g=NSOptUtil.gradBlockDynamics(tInfo,FD.Model,x,FD.U(:,ix),FD.V(:,ix),tau);
            else
                SD=SYSDATA(FD.Model,iC);
                if FD.Type==4
                    g=NSOptUtil.gradSectorDynamics(SD,tInfo,x,FD,FD.U(:,ix),FD.V(:,ix),tau);
                else
                    g=NSOptUtil.gradLoopDynamics(SD,tInfo,x,SD.xStab,FD.U(:,ix),FD.V(:,ix),tau);
                end
            end
            g(isnan(g))=0;
        end
