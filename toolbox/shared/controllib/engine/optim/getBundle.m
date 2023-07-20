function[fB,JB,g]=getBundle(x,hObj,SPECDATA,SYSDATA,tInfo,OPTS)







    wStab=OPTS.wStab;
    MINDECAY=OPTS.MinDecay;
    MAXRAD=OPTS.MaxRadius;
    CUT=max(10*MINDECAY,MINDECAY^0.66);
    Ts=tInfo.Ts;
    np=numel(x);
    fB=zeros(0,1);
    JB=zeros(np,0);


    CheckStable=true(size(SYSDATA));
    for ct=1:numel(SPECDATA)
        FD=SPECDATA(ct);
        iM=FD.Model;
        iC=FD.Config;
        fWeight=FD.fWeight;
        fObj=hObj/fWeight;


        if FD.Stabilize
            E=[];
            if iC==0

                E=FD.E;
            else
                SD=SYSDATA(iM,iC);
                if FD.Type==4

                    E=FD.E;
                elseif CheckStable(iM,iC)
                    E=SD.Es;
                    CheckStable(iM,iC)=false;
                end
            end


            if Ts>0
                realE=log(abs(E));
            else
                realE=real(E);
            end
            iStab=find(realE>=-CUT&imag(E)>=0);
            if~isempty(iStab)
                fB=[fB;wStab*(2+realE(iStab)/MINDECAY)];
                mu=wStab/MINDECAY;
                if Ts>0
                    tau=mu*E(iStab)./(abs(E(iStab)).^2);
                    if iC==0
                        JB=[JB,NSOptUtil.gradBlockDynamics(tInfo,iM,x,FD.U(:,iStab),FD.V(:,iStab),tau)];
                    elseif FD.Type==4
                        JB=[JB,NSOptUtil.gradSectorDynamics(SD,tInfo,x,FD,FD.U(:,iStab),FD.V(:,iStab),tau)];
                    else
                        JB=[JB,NSOptUtil.gradLoopDynamics(SD,tInfo,x,SD.xStab,SD.Us(:,iStab),SD.Vs(:,iStab),tau)];
                    end
                else
                    if iC==0
                        JB=[JB,mu*NSOptUtil.gradBlockDynamics(tInfo,iM,x,FD.U(:,iStab),FD.V(:,iStab))];
                    elseif FD.Type==4
                        JB=[JB,mu*NSOptUtil.gradSectorDynamics(SD,tInfo,x,FD,FD.U(:,iStab),FD.V(:,iStab))];
                    else
                        JB=[JB,mu*NSOptUtil.gradLoopDynamics(SD,tInfo,x,SD.xStab,SD.Us(:,iStab),SD.Vs(:,iStab))];
                    end
                end
            end


            if Ts==0&&iC>0
                absE=abs(E);
                iRad=find(absE>=MAXRAD/10&imag(E)>=0);
                if~isempty(iRad)

                    mu=wStab/MAXRAD;
                    fB=[fB;mu*absE(iRad)];
                    tau=mu*(E(iRad)./absE(iRad));
                    if FD.Type==4
                        JB=[JB,NSOptUtil.gradSectorDynamics(SD,tInfo,x,FD,FD.U(:,iRad),FD.V(:,iRad),tau)];
                    else
                        JB=[JB,NSOptUtil.gradLoopDynamics(SD,tInfo,x,SD.xStab,SD.Us(:,iRad),SD.Vs(:,iRad),tau)];
                    end
                end
            end
        end

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

            fSpec=zeros(nE,3);tau=zeros(nE,3);
            if alpha<0
                fSpec(:,1)=realE/(-alpha);tau(:,1)=-1/alpha;
            else
                aux=[realE/(-alpha),(realE./absE)/(-zeta)];
                fSpec(:,1:2)=NSOptUtil.SpectralPenalty(aux);
                gaux=NSOptUtil.gradSpectralPenalty(aux);
                tau(:,1)=gaux(:,1)/(-alpha);
                tau(:,2)=complex(0,(gaux(:,2).*imag(E)./absE.^3)/zeta).*E;
            end
            fSpec(:,3)=absE/rho;tau(:,3)=(E./absE)/rho;
            for jSpec=1:3
                iAct=find(fSpec(:,jSpec)>fObj/2&imag(E)>=0&inFocus);
                if~isempty(iAct)
                    if Ts>0
                        tau(:,jSpec)=tau(:,jSpec)./conj(Ts*E0);
                    end
                    if iC==0
                        JSpec=NSOptUtil.gradBlockDynamics(tInfo,iM,x,U(:,iAct),V(:,iAct),tau(iAct,jSpec));
                    else
                        JSpec=NSOptUtil.gradLoopDynamics(SD,tInfo,x,FD.xPerf,U(:,iAct),V(:,iAct),tau(iAct,jSpec));
                    end
                    fB=[fB;fWeight*fSpec(iAct,jSpec)];JB=[JB,fWeight*JSpec];
                end
            end
        else

            SD=SYSDATA(iM,iC);
            if FD.fObj>fObj/2
                switch FD.Type
                case{1,3,4}

                    [fPerf,JPerf]=localGetHinfBundle(x,fObj,FD,SD,tInfo,OPTS,Ts);
                case 2

                    JPerf=NSOptUtil.gradH2Perf(FD,SD,tInfo,x);
                    fPerf=FD.fObj;
                end
                fB=[fB;fWeight*fPerf];JB=[JB,fWeight*JPerf];%#ok<*AGROW>
            end
        end
    end



    JB(isnan(JB))=0;


    if isempty(fB)

        g=zeros(np,1);
    else
        [~,iAct]=max(fB);
        g=JB(:,iAct);
    end



    function[fS,JS]=localGetHinfBundle(x,fObj,SPECDATA,SYSDATA,tInfo,OPTS,Ts)

        Acl=SPECDATA.Acl;Bcl=SPECDATA.Bcl;Ccl=SPECDATA.Ccl;Dcl=SPECDATA.Dcl;
        nxaug=size(Acl,1);
        [ny,nu]=size(Dcl);
        clp=SYSDATA.Ep;
        fBand=SPECDATA.Band;
        fpeak=SPECDATA.PeakFreq;
        hp=SPECDATA.HamEigs;

        SectorBound=(SPECDATA.Type==4);
        if SectorBound
            RMAX=OPTS.Rmax;
            W1=SPECDATA.Sector.W1;nw1=size(W1,2);
            W2=SPECDATA.Sector.W2;nw2=size(W2,2);
        end

        if nxaug>0


            T=SPECDATA.Transform;
            if~(isempty(T)||isempty(T.h))

                fObj=T.h(fObj,-1);
            end
            GCUT=fObj/2;

            DAMPFACT=1e-3;




            ahp=abs(hp);
            rhp=real(hp);
            freqB=ahp(rhp>=0&rhp<0.5*ahp);


            freqB=[freqB(freqB>fBand(1)&freqB<fBand(2));fBand.'];


            freqB=[freqB(freqB<0.9*fpeak);fpeak;freqB(freqB>1.1*fpeak)];
            nf=length(freqB);






            if Ts>0
                s=log(clp)/Ts;
            else
                s=clp;
            end
            idxRes=abs(real(s))<DAMPFACT*imag(s);
            wRes=abs(s(idxRes,:));
            isResonant=false(nf,1);
            for ct=1:numel(wRes)
                isResonant(abs(1-freqB/wRes(ct))<DAMPFACT)=true;
            end




            if Ts>0
                sz=complex(cos(Ts*freqB),sin(Ts*freqB));
            else
                sz=complex(0,freqB);
            end
            if SectorBound

                W12=[W1,W2];
                [hB,~,~,hScale]=ssfresp(Acl,Bcl,W12'*Ccl,W12'*Dcl,[],sz);
                RObj=zeros(nf,1);U=zeros(ny,nf);V=zeros(nu,nf);
                for ct=1:nf
                    [~,uR,vR,wR,c1,s1]=ltipack.util.gsvmax(...
                    hB(1:nw1,:,ct),hB(nw1+1:nw1+nw2,:,ct),hScale(ct));
                    RObj(ct)=c1/(s1+c1/RMAX);
                    if~isempty(uR)
                        U(:,ct)=(s1*W1*uR-c1*W2*vR)/(s1+c1/RMAX)^2;V(:,ct)=wR;
                    end
                end
                isel=find(RObj>GCUT|isResonant);
            else

                [hB,~,gFro]=ssfresp(Acl,Bcl,Ccl,Dcl,[],sz);
                isel=find(gFro>GCUT|isResonant);
            end
            freqB=freqB(isel);
        else

            freqB=fBand(1);isel=1;
            if SectorBound
                [~,uR,vR,wR,c1,s1]=ltipack.util.gsvmax(W1'*Dcl,W2'*Dcl,norm(Dcl,1));
                RObj=c1/(s1+c1/RMAX);
                if isempty(uR)
                    U=zeros(ny,1);V=zeros(nu,1);
                else
                    U=(s1*W1*uR-c1*W2*vR)/(s1+c1/RMAX)^2;V=wR;
                end
            else
                hB=Dcl;
            end
        end



        if SectorBound
            [JS,fS]=NSOptUtil.gradRelIndex(SPECDATA,SYSDATA,tInfo,RMAX,x,...
            freqB,RObj(isel),U(:,isel),V(:,isel));
        else
            [JS,fS]=NSOptUtil.gradHinfPerf(SPECDATA,SYSDATA,tInfo,x,freqB,hB,isel);
        end


