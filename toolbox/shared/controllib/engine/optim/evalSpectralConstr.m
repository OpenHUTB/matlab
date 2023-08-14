function[SPECDATA,SYSDATA]=evalSpectralConstr(p,fTest,SPECDATA,SYSDATA,tInfo,OPTS)





    nspec=numel(SPECDATA);
    evalOrder=tInfo.SpecEvalOrder;
    MINDECAY=OPTS.MinDecay;
    Ts=tInfo.Ts;


    for ct=1:nspec
        SPECDATA(ct).fStab=-Inf;
    end


    NeedsUpdate=true(size(SYSDATA));
    for ct=1:nspec
        k=evalOrder(ct);
        iM=SPECDATA(k).Model;
        iC=SPECDATA(k).Config;
        SectorFlag=(SPECDATA(k).Type==4);
        if iC>0&&NeedsUpdate(iM,iC)

            SYSDATA(iM,iC)=NSOptUtil.evalLFT(SYSDATA(iM,iC),tInfo,p);
            NeedsUpdate(iM,iC)=false;
        end


        if iC==0

            A=NSOptUtil.evalBlock(tInfo,iM,p);
        else
            SD=SYSDATA(iM,iC);
            if SectorFlag

                A=NSOptUtil.evalSectorCondition(SD,SPECDATA(k));





            else

                A=SD.Acl(SD.xStab,SD.xStab);
            end
        end


        if hasInfNaN(A)

            f=Inf;
        else
            [V,E,U]=eig(A,'vector');

            if~SectorFlag


                if Ts>0
                    isFixed=(abs(E-1)<MINDECAY);
                else
                    isFixed=(abs(E)<MINDECAY);
                end
                iF=find(isFixed);


                if iC>0
                    J=NSOptUtil.gradLoopDynamics(SD,tInfo,p,SD.xStab,U(:,iF),V(:,iF));
                else
                    J=NSOptUtil.gradBlockDynamics(tInfo,iM,p,U(:,iF),V(:,iF));
                end

                isFixed(iF)=(sum(abs(J))*(1+norm(p))<MINDECAY);
                if any(isFixed)
                    isM=(~isFixed);
                    E=E(isM,:);
                    U=U(:,isM);
                    V=V(:,isM);
                end
            end


            if isempty(E)
                f=-Inf;
            else
                if Ts>0


                    realE=log(abs(E));
                else
                    realE=real(E);
                end
                f=max(realE)+MINDECAY;
            end
        end
        SPECDATA(k).fStab=f;
        if f>=fTest
            break
        end

        SPECDATA(k).E=E;
        SPECDATA(k).U=U;
        SPECDATA(k).V=V;
    end


