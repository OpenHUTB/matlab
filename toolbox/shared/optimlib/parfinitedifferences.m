function[gradf,JacCineqTrans,JacCeqTrans,numEvals,evalOK]=parfinitedifferences(xCurrent,...
    lb,ub,fCurrent,cIneqCurrent,cEqCurrent,variables,...
    options,sizes,gradf,JacCineqTrans,JacCeqTrans,finDiffFlags,fscale,varargin)






























































































    fwdFinDiff=finDiffFlags.fwdFinDiff;
    isGrad=finDiffFlags.isGrad;
    hasLBs=finDiffFlags.hasLBs;
    hasUBs=finDiffFlags.hasUBs;

    noBounds=~any(hasLBs|hasUBs);





    fCurrent=fCurrent(:);


    TypicalX=options.TypicalX;
    DiffMinChange=options.DiffMinChange;
    DiffMaxChange=options.DiffMaxChange;
    nVar=numel(variables);
    FinDiffRelStep=options.FinDiffRelStep;


    definedGrad=true(nVar,1);

    if~isGrad



        jacf=gradf;
    end


    JacCineqTrans=JacCineqTrans';
    JacCeqTrans=JacCeqTrans';

    if fwdFinDiff
        parfor(gcnt=1:nVar)



            [objfun,constrfun]=getSetOptimFcns();

            finDiffStep=FinDiffRelStep(gcnt)*nonzerosign(xCurrent(gcnt))*max(abs(xCurrent(gcnt)),abs(TypicalX(gcnt)));

            finDiffStep=nonzerosign(finDiffStep)*min(max(abs(finDiffStep),DiffMinChange),DiffMaxChange);
            modifiedStep=false;
            if hasLBs(gcnt)||hasUBs(gcnt)

                [finDiffStep,modifiedStep]=fwdFinDiffInsideBnds(xCurrent(gcnt),lb(gcnt),ub(gcnt),...
                finDiffStep,gcnt,DiffMinChange);
            end

            [evalOK,fPert,cIneqPert,cEqPert]=finDiffEvalAndChkErr(objfun,constrfun,...
            gcnt,finDiffStep,xCurrent,finDiffFlags,fscale,sizes,varargin{:});

            if~evalOK




                if~modifiedStep
                    finDiffStep=-finDiffStep;
                    insideBnds=...
                    (hasLBs(gcnt)&&xCurrent(gcnt)+finDiffStep>=lb(gcnt))&&...
                    (hasUBs(gcnt)&&xCurrent(gcnt)+finDiffStep<=ub(gcnt));
                    if noBounds||insideBnds
                        [evalOK,fPert,cIneqPert,cEqPert]=finDiffEvalAndChkErr(objfun,constrfun,...
                        gcnt,finDiffStep,xCurrent,finDiffFlags,fscale,sizes,varargin{:});
                    end
                end
                if~evalOK


                    if finDiffFlags.isGrad
                        fPert=NaN;
                        cIneqPert=NaN(sizes.mNonlinIneq,1);
                        cEqPert=NaN(sizes.mNonlinEq,1);
                    else
                        fPert=NaN(numel(fCurrent),1);
                    end
                end
            end
            definedGrad(gcnt)=evalOK;

            if~isempty(objfun)
                if isGrad
                    gradf(gcnt)=(fPert-fCurrent)/finDiffStep;
                else
                    jacf(:,gcnt)=(fPert(:)-fCurrent)/finDiffStep;
                end
            end

            if~isempty(constrfun)

                JacCineqTrans(:,gcnt)=(cIneqPert-cIneqCurrent)'/finDiffStep;
                JacCeqTrans(:,gcnt)=(cEqPert-cEqCurrent)'/finDiffStep;
            end
        end
        numEvals=numel(variables);
    else
        parfor(gcnt=1:nVar)



            [objfun,constrfun]=getSetOptimFcns();

            finDiffStep=FinDiffRelStep(gcnt)*max(abs(xCurrent(gcnt)),abs(TypicalX(gcnt)));

            finDiffStep=nonzerosign(finDiffStep)*min(max(abs(finDiffStep),DiffMinChange),DiffMaxChange);
            if hasLBs(gcnt)||hasUBs(gcnt)

                [finDiffStep,formulaType]=cntrlFinDiffInsideBnds(xCurrent(gcnt),...
                lb(gcnt),ub(gcnt),finDiffStep,gcnt,DiffMinChange);
            else
                formulaType=0;
            end


            if formulaType==0
                delta1=-finDiffStep;
                delta2=finDiffStep;
            elseif formulaType==-1
                delta1=-2*finDiffStep;
                delta2=-finDiffStep;
            else
                delta1=finDiffStep;
                delta2=2*finDiffStep;
            end




            evalOK=true;fPert1=NaN;fPert2=NaN;
            cIneqPert1=NaN;cIneqPert2=NaN;cEqPert1=NaN;cEqPert2=NaN;

            stop=false;
            while~stop
                stop=true;

                [evalOK,fPert1,cIneqPert1,cEqPert1]=finDiffEvalAndChkErr(objfun,...
                constrfun,gcnt,delta1,xCurrent,finDiffFlags,fscale,sizes,varargin{:});

                if~evalOK
                    if formulaType==0


                        if noBounds||(hasUBs(gcnt)&&(xCurrent(gcnt)+2*finDiffStep<=ub(gcnt)))


                            formulaType=1;
                            delta1=finDiffStep;
                            delta2=2*finDiffStep;
                            stop=false;
                        end
                    end
                else

                    [evalOK,fPert2,cIneqPert2,cEqPert2]=finDiffEvalAndChkErr(objfun,...
                    constrfun,gcnt,delta2,xCurrent,finDiffFlags,fscale,sizes,varargin{:});


                    if~evalOK
                        if formulaType==0


                            if noBounds||(hasLBs(gcnt)&&(xCurrent(gcnt)-2*finDiffStep>=lb(gcnt)))
                                formulaType=-1;
                                delta1=-2*finDiffStep;
                                delta2=-finDiffStep;
                                stop=false;
                            end
                        end
                    end
                end
            end
            definedGrad(gcnt)=evalOK;


            if~isempty(objfun)
                if isGrad
                    gradf(gcnt)=twoStepFinDiffFormulas(formulaType,finDiffStep,...
                    fCurrent,fPert1,fPert2);
                else
                    jacf(:,gcnt)=twoStepFinDiffFormulas(formulaType,finDiffStep,...
                    fCurrent,fPert1,fPert2);
                end
            end

            if~isempty(constrfun)

                workArrayIneq=twoStepFinDiffFormulas(formulaType,finDiffStep,...
                cIneqCurrent,cIneqPert1,cIneqPert2);
                JacCineqTrans(:,gcnt)=workArrayIneq;
                workArrayEq=twoStepFinDiffFormulas(formulaType,finDiffStep,...
                cEqCurrent,cEqPert1,cEqPert2);
                JacCeqTrans(:,gcnt)=workArrayEq;
            end
        end
        numEvals=2*numel(variables);
    end

    evalOK=all(definedGrad);
    if~evalOK
        gradf=[];
        JacCineqTrans=[];
        JacCeqTrans=[];
    end

    if~isGrad

        gradf=jacf;
    end


    JacCineqTrans=JacCineqTrans';
    JacCeqTrans=JacCeqTrans';