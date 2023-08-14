function[evalOK,gradf,JacCineqTrans,JacCeqTrans,xk,obj]=...
    computeForwardDifferences(obj,fCurrent,cIneqCurrent,ineq0,cEqCurrent,eq0,...
    xk,gradf,JacCineqTrans,CineqColStart,ldJI,...
    JacCeqTrans,CeqColStart,ldJE,...
    lb,ub,scales,options,runTimeOptions,varargin)







































































%#codegen

    coder.allowpcode('plain');




    validateattributes(cIneqCurrent,{'double'},{'2d'});
    validateattributes(ineq0,{coder.internal.indexIntClass},{'scalar'});

    validateattributes(cEqCurrent,{'double'},{'2d'});
    validateattributes(eq0,{coder.internal.indexIntClass},{'scalar'});


    validateattributes(gradf,{'double'},{'2d'});

    validateattributes(JacCineqTrans,{'double'},{'2d'});
    validateattributes(CineqColStart,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldJI,{coder.internal.indexIntClass},{'scalar'});

    validateattributes(JacCeqTrans,{'double'},{'2d'});
    validateattributes(CeqColStart,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldJE,{coder.internal.indexIntClass},{'scalar'});

    validateattributes(lb,{'double'},{'2d'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(scales,{'struct'},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(runTimeOptions,{'struct'},{'scalar'});

    coder.internal.prefer_const(ldJI,ldJE,options,runTimeOptions,scales,varargin{:});

    INT_ONE=coder.internal.indexInt(1);
    FORWARD_DELTA=coder.const(optim.coder.utils.FiniteDifferences.Constants.FiniteDifferenceType('FORWARD'));

    evalOK=true;
    obj.numEvals=coder.internal.indexInt(0);



    for idx=1:obj.nVar

        modifiedStep=false;
        deltaX=optim.coder.utils.FiniteDifferences.computeDeltaX(FORWARD_DELTA,xk,idx,runTimeOptions.FiniteDifferenceStepSize,runTimeOptions.TypicalX);

        if obj.hasLB(idx)||obj.hasUB(idx)



            if obj.hasLB(idx)&&obj.hasUB(idx)
                [deltaX,modifiedStep]=...
                optim.coder.utils.FiniteDifferences.internal.fwdFinDiffInsideBnds(xk(idx),lb(idx),ub(idx),deltaX);
            elseif obj.hasUB(idx)
                [deltaX,modifiedStep]=...
                optim.coder.utils.FiniteDifferences.internal.fwdFinDiffInsideBnds_ub(xk(idx),ub(idx),deltaX);
            else
                [deltaX,modifiedStep]=...
                optim.coder.utils.FiniteDifferences.internal.fwdFinDiffInsideBnds_lb(xk(idx),lb(idx),deltaX);
            end
        end

        [evalOK,obj.f_1,obj.cIneq_1,obj.cEq_1,xk]=...
        optim.coder.utils.FiniteDifferences.internal.finDiffEvalAndChkErr(obj,obj.f_1,obj.cIneq_1,obj.cEq_1,idx,deltaX,xk,...
        options.NonFiniteSupport,options.ScaleProblem,scales,varargin{:});

        obj.numEvals=obj.numEvals+1;



        if~evalOK&&options.NonFiniteSupport




            if~modifiedStep
                deltaX=-deltaX;
                insideBnds=...
                (obj.hasLB(idx)&&xk(idx)+deltaX>=lb(idx))&&...
                (obj.hasUB(idx)&&xk(idx)+deltaX<=ub(idx));
                if~obj.hasBounds||insideBnds
                    [evalOK,obj.f_1,obj.cIneq_1,obj.cEq_1,xk]=...
                    optim.coder.utils.FiniteDifferences.internal.finDiffEvalAndChkErr(obj,obj.f_1,obj.cIneq_1,obj.cEq_1,idx,deltaX,xk,...
                    options.NonFiniteSupport,options.ScaleProblem,scales,varargin{:});

                    obj.numEvals=obj.numEvals+1;
                end
            end
            if~evalOK



                break;
            end
        end

        if~(isempty(obj.objfun)||options.SpecifyObjectiveGradient)
            gradf(idx)=(obj.f_1-fCurrent)/deltaX;
        end

        if~(isempty(obj.nonlin)||options.SpecifyConstraintGradient)
            for idx_row=1:obj.mIneq
                idxJI=idx+ldJI*(CineqColStart+idx_row-1-INT_ONE);
                JacCineqTrans(idxJI)=(obj.cIneq_1(idx_row)-cIneqCurrent(ineq0+idx_row-1))/deltaX;
            end
            for idx_row=1:obj.mEq
                idxJE=idx+ldJE*(CeqColStart+idx_row-1-INT_ONE);
                JacCeqTrans(idxJE)=(obj.cEq_1(idx_row)-cEqCurrent(eq0+idx_row-1))/deltaX;
            end
        end

    end

end

