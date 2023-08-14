function[SPECDATA,SYSDATA,tInfo]=evalObjective(p,hTest,SPECDATA,SYSDATA,tInfo,OPTS)





    nspec=numel(SPECDATA);
    evalOrder=tInfo.SpecEvalOrder;
    wStab=OPTS.wStab;
    MINDECAY=OPTS.MinDecay;
    MAXRAD=OPTS.MaxRadius;
    if isempty(wStab)

        wStab=1;
    end
    Ts=tInfo.Ts;
    TuneFlag=isempty(tInfo.UncertainBlocks);


    for ct=1:nspec
        SPECDATA(ct).fStab=-Inf;
        SPECDATA(ct).fObj=-Inf;
    end


    if TuneFlag
        tInfo=NSOptUtil.evalScaling(tInfo,p);
    end


    NeedsUpdate=true(size(SYSDATA));
    CheckStable=true(size(SYSDATA));
    for ct=1:nspec
        k=evalOrder(ct);
        FD=SPECDATA(k);
        iM=FD.Model;
        iC=FD.Config;
        fWeight=FD.fWeight;
        SectorFlag=(FD.Type==4);



        E=[];
        if iC==0

            if TuneFlag

                A=NSOptUtil.evalBlock(tInfo,iM,p);
                [FD.V,FD.E,FD.U]=eig(A,'vector');

                FD=localElimFixedIntegrator(FD,tInfo,iM,p,MINDECAY);
            end
            if FD.Stabilize

                E=FD.E;
            end
        else
            if NeedsUpdate(iM,iC)

                SD=NSOptUtil.evalLFT(SYSDATA(iM,iC),tInfo,p);
                if SD.LFTData.SingularFlag

                    SPECDATA(k).fStab=Inf;break
                end

                SD=localAnalyzeDynamics(SD,tInfo,p,MINDECAY);

                if isempty(SD.Scaling.sx)
                    [~,~,~,~,SD.Scaling.sx]=...
                    xscale(SD.Acl,SD.Bcl,SD.Ccl,SD.Dcl,[],Ts);
                end
                SYSDATA(iM,iC)=SD;
                NeedsUpdate(iM,iC)=false;
            end
            SD=SYSDATA(iM,iC);
            if SectorFlag

                [A,FD]=NSOptUtil.evalSectorCondition(SD,FD);
                if hasInfNaN(A)
                    SPECDATA(k).fStab=Inf;break
                end
                [FD.V,FD.E,FD.U]=eig(A,'vector');
                E=FD.E;
            elseif FD.Stabilize&&CheckStable(iM,iC)

                E=SD.Es;
                CheckStable(iM,iC)=false;
            end
        end


        fStab=-Inf;
        if~isempty(E)
            if Ts>0


                realE=log(abs(E));
            else
                realE=real(E);
            end
            if any(realE>=-MINDECAY/10)

                fStab=Inf;
            elseif TuneFlag

                fStab=2+max(realE)/MINDECAY;
            end
        end
        FD.fStab=fStab;
        if wStab*fStab>=hTest
            SPECDATA(k)=FD;break
        end




        fRad=-Inf;
        if~isempty(E)&&Ts==0&&iC>0
            fRad=max(abs(E))/MAXRAD;
        end
        FD.fRad=fRad;
        if wStab*fRad>=hTest
            SPECDATA(k)=FD;break
        end


        if FD.Type==0

            if iC>0

                [FD.V,FD.E,FD.U]=localSubDynamics(SYSDATA(iM,iC),FD.xPerf);
            end

            E=FD.E;
            if Ts>0
                E=log(E(E~=0))/Ts;
            end
            if iC>0
                wnE=abs(E);
                E=E(wnE>=FD.Band(1)&wnE<=FD.Band(2));
            end

            if isempty(E)
                fObj=0;
            else
                fRad=max(abs(E))/FD.Spectral.MaxFrequency;
                if FD.Spectral.MinDecay<0

                    fSpec=[max(real(E)/(-FD.Spectral.MinDecay)),-Inf,fRad];
                else
                    fSpec=[NSOptUtil.SpectralPenalty([...
                    min(-real(E))/FD.Spectral.MinDecay,...
                    min(-real(E)./abs(E))/FD.Spectral.MinDamping]),fRad];
                end
                fObj=max(fSpec);
            end
        else



            SD=SYSDATA(iM,iC);
            fObjTest=hTest/fWeight;
            if SectorFlag
                clp=FD.E;
            else
                clp=SD.Ep;
            end


            iu=FD.Input;iy=FD.Output;xPerf=FD.xPerf;
            sx=SD.Scaling.sx(xPerf,:);
            Acl=sx.\SD.Acl(xPerf,xPerf).*sx';
            Bcl=sx.\SD.Bcl(xPerf,iu);
            Ccl=SD.Ccl(iy,xPerf).*sx';
            Dcl=SD.Dcl(iy,iu);


            if FD.DScaling.Dynamic>0

                DL=tInfo.DL;
                [Acl,Bcl,Ccl,Dcl]=ltipack.ssops('mult',...
                DL.a,DL.b(:,iy),DL.c(iy,:),DL.d(iy,iy),[],Acl,Bcl,Ccl,Dcl,[]);
                DR=tInfo.DR;
                [Acl,Bcl,Ccl,Dcl]=ltipack.ssops('mult',...
                Acl,Bcl,Ccl,Dcl,[],DR.a,DR.b(:,iu),DR.c(iu,:),DR.d(iu,iu),[]);
                clp=[clp;DL.Poles;DR.Poles];
            elseif FD.DScaling.Static

                dL=tInfo.DL.d(iy,iy);
                dR=tInfo.DR.d(iu,iu);
                Bcl=Bcl*dR;Ccl=dL*Ccl;Dcl=dL*Dcl*dR;
            end


            T=FD.Transform;
            if~isempty(T)

                Bcl=Bcl*T.G;
                Ccl=T.F*Ccl;
                Dcl=T.F*Dcl*T.G;

                if isempty(T.E.a)
                    Dcl=T.E.d+Dcl;
                else
                    [Acl,Bcl,Ccl,Dcl]=ltipack.ssops('add',T.E.a,T.E.b,T.E.c,T.E.d,[],...
                    Acl,Bcl,Ccl,Dcl,[]);
                    clp=[clp;T.E.Poles];
                end
            end


            if~isempty(FD.WL)
                [Acl,Bcl,Ccl,Dcl]=ltipack.ssops('mult',...
                FD.WL.a,FD.WL.b,FD.WL.c,FD.WL.d,[],Acl,Bcl,Ccl,Dcl,[]);
                clp=[clp;FD.WL.Poles];%#ok<*AGROW>
            end
            if~isempty(FD.WR)
                [Acl,Bcl,Ccl,Dcl]=ltipack.ssops('mult',...
                Acl,Bcl,Ccl,Dcl,[],FD.WR.a,FD.WR.b,FD.WR.c,FD.WR.d,[]);
                clp=[clp;FD.WR.Poles];
            end


            if FD.Type==2



                FD.Acl=Acl;FD.Bcl=Bcl;FD.Ccl=Ccl;FD.Dcl=Dcl;
                try
                    if Ts>0
                        RY=dlyapchol(Acl',Ccl',[],'noscale');
                        fObj=norm([RY*Bcl;Dcl],'fro');
                    else
                        RY=lyapchol(Acl',Ccl',[],'noscale');
                        fObj=norm(RY*Bcl,'fro');
                    end
                    FD.RY=RY;
                catch

                    fObj=Inf;
                end
            else


                [Ucl,Acl]=hess(Acl);
                Bcl=Ucl'*Bcl;Ccl=Ccl*Ucl;
                FD.Acl=Acl;FD.Bcl=Bcl;FD.Ccl=Ccl;FD.Dcl=Dcl;
                FD.Ucl=Ucl;

                clp=clp(imag(clp)>=0);
                if Ts>0
                    w0=abs(log(clp)/Ts);
                else
                    w0=abs(clp);
                end
                if SectorFlag

                    RMAX=OPTS.Rmax;
                    aux=min(fObjTest/RMAX,1);
                    RTest=aux/(1-aux)*RMAX;
                    [R,FD.PeakFreq,FD.HamEigs]=...
                    ltipack.relConicIndex(Acl,Bcl,Ccl,Dcl,[],Ts,...
                    FD.Sector.W1,FD.Sector.W2,OPTS.TolHinf,RTest,w0,FD.Band,true);

                    fObj=1/(1/R+1/RMAX);
                else

                    if~(isempty(T)||isempty(T.h))
                        fObjTest=T.h(fObjTest,-1);
                    end

                    [fObj,FD.PeakFreq,FD.HamEigs]=...
                    ltipack.norminf(Acl,Bcl,Ccl,Dcl,[],Ts,OPTS.TolHinf,fObjTest,w0,FD.Band,true);
                end
            end

            if~(isempty(T)||isempty(T.h))

                fObj=T.h(fObj,0);
            end
        end


        FD.fObj=fObj;
        SPECDATA(k)=FD;
        if FD.fWeight*fObj>=hTest
            break
        end
    end


    function SD=localAnalyzeDynamics(SD,tInfo,p,MINDECAY)



        xPerf=SD.xPerf;
        Acl=SD.Acl(xPerf,xPerf);
        [V,E,U]=eig(Acl,'vector');


        SD.FixedInteg.Active=false;
        SD.Uf=[];SD.Vf=[];
        if SD.FixedInteg.Check
            if tInfo.Ts>0
                isFixed=(abs(E-1)<MINDECAY);
            else
                isFixed=(abs(E)<MINDECAY);
            end
            J=NSOptUtil.gradLoopDynamics(SD,tInfo,p,xPerf,U(:,isFixed),V(:,isFixed));
            isFixed(isFixed)=(sum(abs(J))*(1+norm(p))<MINDECAY);
            iF=find(isFixed);
            if~isempty(iF)

                [SD.FixedInteg,dAcl]=localActivateFixedInteg(SD.FixedInteg,Acl,U,V,iF,MINDECAY);
                SD.Acl(xPerf,xPerf)=Acl+dAcl;

                SD.Uf=U(:,iF);SD.Vf=V(:,iF);


                iT=find(~isFixed);
                E=E(iT);U=U(:,iT);V=V(:,iT);
            end
        end


        SD.Ep=E;SD.Up=U;SD.Vp=V;


        [SD.Vs,SD.Es,SD.Us]=localSubDynamics(SD,SD.xStab);



        function[V,E,U]=localSubDynamics(SD,xSpec)


            nx=numel(xSpec);
            xPerf=SD.xPerf;
            if nx==0
                E=zeros(0,1);U=[];V=[];
            elseif nx==numel(xPerf)
                E=SD.Ep;U=SD.Up;V=SD.Vp;
            else


                [V,E,U]=eig(SD.Acl(xSpec,xSpec),'vector');

                nFixed=size(SD.Uf,2);
                if nFixed>0
                    tol=1e-6;
                    isFixed=false(1,nx);
                    inSpec=ismember(xPerf,xSpec);
                    A=SD.Acl(xPerf,xPerf);
                    for ct=1:nFixed
                        uf=SD.Uf(:,ct);
                        vf=SD.Vf(:,ct);
                        if norm(A(inSpec,~inSpec)*vf(~inSpec))<tol*norm(A(inSpec,inSpec)*vf(inSpec))&&...
                            norm(uf(~inSpec)'*A(~inSpec,inSpec))<tol*norm(uf(inSpec)'*A(inSpec,inSpec))


                            ufSpec=uf(inSpec);
                            vfSpec=vf(inSpec);
                            isFixed=isFixed|(abs(ufSpec'*U)>(1-tol)*norm(ufSpec)&...
                            abs(vfSpec'*V)>(1-tol)*norm(vfSpec));
                        end
                    end
                    iT=find(~isFixed);
                    E=E(iT);U=U(:,iT);V=V(:,iT);
                end
            end



            function FD=localElimFixedIntegrator(FD,tInfo,iblk,p,MINDECAY)

                if tInfo.Ts>0
                    isFixed=(abs(FD.E-1)<MINDECAY);
                else
                    isFixed=(abs(FD.E)<MINDECAY);
                end

                iF=find(isFixed);
                J=NSOptUtil.gradBlockDynamics(tInfo,iblk,p,FD.U(:,iF),FD.V(:,iF));
                isFixed(iF)=(sum(abs(J))*(1+norm(p))<MINDECAY);
                if any(isFixed)
                    isM=(~isFixed);
                    FD.E=FD.E(isM,:);
                    FD.U=FD.U(:,isM);
                    FD.V=FD.V(:,isM);
                end


                function[FID,dAcl]=localActivateFixedInteg(FID,Acl,U,V,iF,MINDECAY)

                    FID.Active=true;
                    FID.Shift=MINDECAY;



                    nx=size(V,2);
                    nxF=numel(iF);
                    [QU,~,~]=qr([real(U(:,iF)),imag(U(:,iF))]);
                    [QV,~,~]=qr([real(V(:,iF)),imag(V(:,iF))]);
                    U1=QU(:,1:nxF);V2=QU(:,nxF+1:nx);
                    V1=QV(:,1:nxF);U2=QV(:,nxF+1:nx);
                    U1=U1/(V1'*U1);
                    U2=U2/(V2'*U2);
                    FID.U1=U1;FID.U2=U2;
                    FID.V1=V1;FID.V2=V2;
                    FID.A11=U1'*Acl*V1;
                    FID.A22=U2'*Acl*V2;


                    dAcl=((-MINDECAY)*V1)*U1';












