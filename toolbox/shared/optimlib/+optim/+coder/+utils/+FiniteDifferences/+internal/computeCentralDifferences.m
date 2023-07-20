function[evalOK,gradf,JacCineqTrans,JacCeqTrans,xk,obj]=...
    computeCentralDifferences(obj,fCurrent,cIneqCurrent,ineq0,cEqCurrent,eq0,...
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

    coder.internal.prefer_const(ldJI,ldJE,scales,options,runTimeOptions,varargin{:});

    CENTRAL=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('Central'));
    DOUBLE_LEFT=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('DoubleLeft'));
    DOUBLE_RIGHT=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('DoubleRight'));

    CENTRAL_DELTA=coder.const(optim.coder.utils.FiniteDifferences.Constants.FiniteDifferenceType('CENTRAL'));

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);
    evalOK=true;
    obj.numEvals=INT_ZERO;

    for idx=1:obj.nVar

        deltaX=optim.coder.utils.FiniteDifferences.computeDeltaX(CENTRAL_DELTA,xk,idx,runTimeOptions.FiniteDifferenceStepSize,runTimeOptions.TypicalX);

        if obj.hasLB(idx)||obj.hasUB(idx)



            if obj.hasLB(idx)&&obj.hasUB(idx)
                [deltaX,formulaType]=...
                optim.coder.utils.FiniteDifferences.internal.cntrlFinDiffInsideBnds(xk(idx),lb(idx),ub(idx),deltaX);
            elseif obj.hasUB(idx)
                [deltaX,formulaType]=...
                optim.coder.utils.FiniteDifferences.internal.cntrlFinDiffInsideBnds_ub(xk(idx),ub(idx),deltaX);
            else
                [deltaX,formulaType]=...
                optim.coder.utils.FiniteDifferences.internal.cntrlFinDiffInsideBnds_lb(xk(idx),lb(idx),deltaX);
            end
        else
            formulaType=CENTRAL;
        end



        switch(formulaType)
        case CENTRAL
            delta1=-deltaX;
            delta2=deltaX;
        case DOUBLE_LEFT
            delta1=-2*deltaX;
            delta2=-deltaX;
        otherwise
            delta1=deltaX;
            delta2=2*deltaX;
        end

        stop=false;
        while~stop
            stop=true;

            [evalOK,obj.f_1,obj.cIneq_1,obj.cEq_1,xk]=...
            optim.coder.utils.FiniteDifferences.internal.finDiffEvalAndChkErr(obj,obj.f_1,obj.cIneq_1,obj.cEq_1,idx,delta1,xk,...
            options.NonFiniteSupport,options.ScaleProblem,scales,varargin{:});

            obj.numEvals=obj.numEvals+1;



            if~evalOK&&options.NonFiniteSupport
                if formulaType==CENTRAL


                    if~obj.hasBounds||(obj.hasUB(idx)&&(xk(idx)+2*deltaX<=ub(idx)))


                        formulaType=DOUBLE_RIGHT;
                        delta1=deltaX;
                        delta2=2*deltaX;
                        stop=false;
                    end
                end
            else

                [evalOK,obj.f_2,obj.cIneq_2,obj.cEq_2,xk]=...
                optim.coder.utils.FiniteDifferences.internal.finDiffEvalAndChkErr(obj,obj.f_2,obj.cIneq_2,obj.cEq_2,idx,delta2,xk,...
                options.NonFiniteSupport,options.ScaleProblem,scales,varargin{:});

                obj.numEvals=obj.numEvals+1;

                if~evalOK&&options.NonFiniteSupport
                    if formulaType==CENTRAL


                        if~obj.hasBounds||(obj.hasLB(idx)&&(xk(idx)-2*deltaX>=lb(idx)))
                            formulaType=DOUBLE_LEFT;
                            delta1=-2*deltaX;
                            delta2=-deltaX;
                            stop=false;
                        end
                    end
                end
            end
        end




        if~evalOK&&options.NonFiniteSupport



            break;
        end

        if~(isempty(obj.objfun)||obj.SpecifyObjectiveGradient)
            gradf=optim.coder.utils.FiniteDifferences.internal.twoStepFinDiffFormulas(formulaType,...
            INT_ONE,gradf,idx,INT_ONE,INT_ZERO,deltaX,fCurrent,INT_ONE,obj.f_1,obj.f_2);
        end

        if~(isempty(obj.nonlin)||obj.SpecifyConstraintGradient)
            if(obj.mIneq>0)
                JacCineqTrans=optim.coder.utils.FiniteDifferences.internal.twoStepFinDiffFormulas(formulaType,...
                obj.mIneq,JacCineqTrans,idx,CineqColStart,ldJI,deltaX,cIneqCurrent,ineq0,obj.cIneq_1,obj.cIneq_2);
            end

            if(obj.mEq>0)
                JacCeqTrans=optim.coder.utils.FiniteDifferences.internal.twoStepFinDiffFormulas(formulaType,...
                obj.mEq,JacCeqTrans,idx,CeqColStart,ldJE,deltaX,cEqCurrent,eq0,obj.cEq_1,obj.cEq_2);
            end
        end

    end

end

