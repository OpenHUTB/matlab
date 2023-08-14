function obj=updatePenaltyParam(obj,fval,ineq_workspace,ineq0,mIneq,eq_workspace,eq0,mEq,...
    sqpiter,qpval,x,iReg0,nRegularized,options)

















%#codegen

    coder.allowpcode('plain');


    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(fval,{'double'},{'scalar'});
    validateattributes(ineq_workspace,{'double'},{'2d'});
    validateattributes(ineq0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(eq_workspace,{'double'},{'2d'});
    validateattributes(eq0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(sqpiter,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(qpval,{'double'},{'scalar'});
    validateattributes(x,{'double'},{'vector'});
    validateattributes(iReg0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(nRegularized,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});


    coder.internal.prefer_const(ineq0,mIneq,eq0,mEq,iReg0,nRegularized,options);

    INT_ONE=coder.internal.indexInt(1);

    penaltyParamMin=1e-10;
    penaltyParamTrial=obj.penaltyParam;

    constrViolationEq=optim.coder.fminconsqp.MeritFunction.computeConstrViolationEq_(mEq,eq_workspace,eq0);
    constrViolationIneq=optim.coder.fminconsqp.MeritFunction.computeConstrViolationIneq_(mIneq,ineq_workspace,ineq0);

    constrViolation=constrViolationEq+constrViolationIneq;

    linearizedConstrViolPrev=obj.linearizedConstrViol;
    obj.linearizedConstrViol=coder.internal.blas.xasum(nRegularized,x,iReg0,INT_ONE);

    if(fval==0.0)


        beta=1.0;
    else

        beta=1.5;
    end

    constrViolDelta=constrViolation+linearizedConstrViolPrev-obj.linearizedConstrViol;



    if(constrViolDelta>eps('double')&&qpval>0)



        penaltyParamTrial=beta*qpval/constrViolDelta;
    end






    if(penaltyParamTrial<obj.penaltyParam)



        phi0=obj.initFval+penaltyParamTrial*(obj.initConstrViolationEq+obj.initConstrViolationIneq);
        obj.phi=fval+penaltyParamTrial*constrViolation;

        if(phi0-obj.phi>double(obj.nPenaltyDecreases)*obj.threshold)
            obj.nPenaltyDecreases=obj.nPenaltyDecreases+1;

            if(obj.nPenaltyDecreases*2>sqpiter)
                obj.threshold=10*obj.threshold;
            end
            obj.penaltyParam=max(penaltyParamTrial,penaltyParamMin);
        else
            obj.phi=fval+obj.penaltyParam*constrViolation;
        end
    else
        obj.penaltyParam=max(penaltyParamTrial,penaltyParamMin);
        obj.phi=fval+obj.penaltyParam*constrViolation;
    end

    obj.phiPrimePlus=min(qpval-obj.penaltyParam*constrViolation,0.0);


