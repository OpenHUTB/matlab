function[gradf,JacCineqTrans,JacCeqTrans,numEvals,evalOK]=finitedifferences(...
    xCurrent,objfun,constrfun,lb,ub,fCurrent,cIneqCurrent,cEqCurrent,variables,...
    options,sizes,gradf,JacCineqTrans,JacCeqTrans,finDiffFlags,fscale,varargin)































































































    noBounds=~any(finDiffFlags.hasLBs|finDiffFlags.hasUBs);





    fCurrent=fCurrent(:);

    xCurrent=xCurrent(:);
    if finDiffFlags.fwdFinDiff
        deltaX=options.FinDiffRelStep.*nonzerosign(xCurrent).*max(abs(xCurrent),abs(options.TypicalX(:)));
    else
        deltaX=options.FinDiffRelStep.*max(abs(xCurrent),abs(options.TypicalX(:)));
    end



    deltaX=nonzerosign(deltaX).*min(max(abs(deltaX),options.DiffMinChange),options.DiffMaxChange);
    numEvals=0;



    pass_cnt=0;


    JacCineqTrans=JacCineqTrans';
    JacCeqTrans=JacCeqTrans';

    if finDiffFlags.fwdFinDiff
        for gcnt=variables
            xCElementOrig=xCurrent(gcnt);
            modifiedStep=false;
            if finDiffFlags.hasLBs(gcnt)||finDiffFlags.hasUBs(gcnt)

                [deltaX(gcnt),modifiedStep]=fwdFinDiffInsideBnds(xCElementOrig,...
                lb(gcnt),ub(gcnt),deltaX(gcnt),gcnt,options.DiffMinChange);
            end

            [evalOK,fplus,cIneqPlus,cEqPlus]=finDiffEvalAndChkErr(objfun,...
            constrfun,gcnt,deltaX(gcnt),xCurrent,finDiffFlags,fscale,...
            sizes,varargin{:});
            numEvals=numEvals+1;
            if~evalOK



                if~modifiedStep
                    deltaX(gcnt)=-deltaX(gcnt);
                    insideBnds=...
                    (finDiffFlags.hasLBs(gcnt)&&xCElementOrig+deltaX(gcnt)>=lb(gcnt))&&...
                    (finDiffFlags.hasUBs(gcnt)&&xCElementOrig+deltaX(gcnt)<=ub(gcnt));
                    if noBounds||insideBnds
                        [evalOK,fplus,cIneqPlus,cEqPlus]=finDiffEvalAndChkErr(objfun,...
                        constrfun,gcnt,deltaX(gcnt),xCurrent,finDiffFlags,fscale,...
                        sizes,varargin{:});
                        numEvals=numEvals+1;
                    end
                end
                if~evalOK


                    if finDiffFlags.isGrad
                        gradf=NaN(sizes.nVar,1);
                        JacCineqTrans=NaN(sizes.mNonlinIneq,sizes.nVar);
                        JacCeqTrans=NaN(sizes.mNonlinEq,sizes.nVar);
                    else
                        gradf=NaN(numel(fCurrent),numel(xCurrent));
                        JacCineqTrans=[];
                        JacCeqTrans=[];
                    end
                    break
                end
            end

            if~isempty(objfun)
                if finDiffFlags.isGrad
                    gradf(gcnt)=(fplus-fCurrent)/deltaX(gcnt);
                else
                    pass_cnt=pass_cnt+1;
                    gradf(:,pass_cnt)=(fplus(:)-fCurrent)/deltaX(gcnt);
                end
            end

            if~isempty(constrfun)
                JacCineqTrans(:,gcnt)=(cIneqPlus-cIneqCurrent)/deltaX(gcnt);
                JacCeqTrans(:,gcnt)=(cEqPlus-cEqCurrent)/deltaX(gcnt);
            end
        end
    else
        for gcnt=variables
            xCElementOrig=xCurrent(gcnt);

            if finDiffFlags.hasLBs(gcnt)||finDiffFlags.hasUBs(gcnt)

                [deltaX(gcnt),formulaType]=cntrlFinDiffInsideBnds(xCElementOrig,...
                lb(gcnt),ub(gcnt),deltaX(gcnt),gcnt,options.DiffMinChange);
            else
                formulaType=0;
            end


            if formulaType==0
                delta1=-deltaX(gcnt);
                delta2=deltaX(gcnt);
            elseif formulaType==-1
                delta1=-2*deltaX(gcnt);
                delta2=-deltaX(gcnt);
            else
                delta1=deltaX(gcnt);
                delta2=2*deltaX(gcnt);
            end

            stop=false;
            while~stop
                stop=true;

                [evalOK,fPert1,cIneqPert1,cEqPert1]=finDiffEvalAndChkErr(objfun,...
                constrfun,gcnt,delta1,xCurrent,finDiffFlags,fscale,sizes,varargin{:});
                numEvals=numEvals+1;

                if~evalOK
                    if formulaType==0


                        if noBounds||(finDiffFlags.hasUBs(gcnt)&&...
                            (xCElementOrig+2*deltaX(gcnt)<=ub(gcnt)))


                            formulaType=1;
                            delta1=deltaX(gcnt);
                            delta2=2*deltaX(gcnt);
                            stop=false;
                        end
                    end
                else

                    [evalOK,fPert2,cIneqPert2,cEqPert2]=finDiffEvalAndChkErr(objfun,...
                    constrfun,gcnt,delta2,xCurrent,finDiffFlags,fscale,sizes,varargin{:});
                    numEvals=numEvals+1;

                    if~evalOK
                        if formulaType==0


                            if noBounds||(finDiffFlags.hasLBs(gcnt)&&...
                                (xCElementOrig-2*deltaX(gcnt)>=lb(gcnt)))
                                formulaType=-1;
                                delta1=-2*deltaX(gcnt);
                                delta2=-deltaX(gcnt);
                                stop=false;
                            end
                        end
                    end
                end
            end


            if~evalOK



                if finDiffFlags.isGrad
                    gradf=NaN(sizes.nVar,1);
                    JacCineqTrans=NaN(sizes.mNonlinIneq,sizes.nVar);
                    JacCeqTrans=NaN(sizes.mNonlinEq,sizes.nVar);
                else
                    gradf=NaN(numel(fCurrent),sizes.nVar);
                    JacCineqTrans=[];
                    JacCeqTrans=[];
                end
                break
            end


            if~isempty(objfun)
                if finDiffFlags.isGrad
                    gradf(gcnt)=twoStepFinDiffFormulas(formulaType,deltaX(gcnt),...
                    fCurrent,fPert1,fPert2);
                else
                    pass_cnt=pass_cnt+1;




                    gradf(:,pass_cnt)=twoStepFinDiffFormulas(formulaType,deltaX(gcnt),...
                    fCurrent,fPert1(:),fPert2(:));
                end
            end

            if~isempty(constrfun)
                workArrayIneq=twoStepFinDiffFormulas(formulaType,deltaX(gcnt),...
                cIneqCurrent,cIneqPert1,cIneqPert2);
                JacCineqTrans(:,gcnt)=workArrayIneq;
                workArrayEq=twoStepFinDiffFormulas(formulaType,deltaX(gcnt),...
                cEqCurrent,cEqPert1,cEqPert2);
                JacCeqTrans(:,gcnt)=workArrayEq;
            end
        end
    end



    JacCineqTrans=JacCineqTrans';
    JacCeqTrans=JacCeqTrans';