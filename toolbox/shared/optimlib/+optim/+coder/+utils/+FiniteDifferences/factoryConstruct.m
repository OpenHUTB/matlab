function obj=factoryConstruct(objfun,nonlin,nVar,mCineq,mCeq,lb,ub,options)
























































%#codegen

    coder.allowpcode('plain');




    validateattributes(nVar,{coder.internal.indexIntClass},{'vector'});
    validateattributes(mCineq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mCeq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(options,{'struct'},{'scalar'});

    coder.internal.prefer_const(objfun,nonlin,nVar,mCineq,mCeq,lb,ub,options);


    obj.objfun=objfun;
    obj.nonlin=nonlin;


    obj.f_1=0.0;
    obj.cIneq_1=coder.nullcopy(zeros(mCineq,1,'double'));
    obj.cEq_1=coder.nullcopy(zeros(mCeq,1,'double'));

    obj.f_2=0.0;
    obj.cIneq_2=coder.nullcopy(zeros(mCineq,1,'double'));
    obj.cEq_2=coder.nullcopy(zeros(mCeq,1,'double'));

    obj.nVar=nVar;
    obj.mIneq=mCineq;
    obj.mEq=mCeq;


    obj.numEvals=coder.internal.indexInt(0);


    obj.SpecifyObjectiveGradient=options.SpecifyObjectiveGradient;
    obj.SpecifyConstraintGradient=options.SpecifyConstraintGradient;



    if mCeq+mCineq==0
        obj.isEmptyNonlcon=true;
    else
        obj.isEmptyNonlcon=false;
    end




    obj.hasLB=coder.nullcopy(false(nVar,1));
    obj.hasUB=coder.nullcopy(false(nVar,1));
    obj.hasBounds=false;








    if strcmpi(options.FiniteDifferenceType,'forward')
        obj.FiniteDifferenceType=coder.const(optim.coder.utils.FiniteDifferences.Constants.FiniteDifferenceType('FORWARD'));
    else
        obj.FiniteDifferenceType=coder.const(optim.coder.utils.FiniteDifferences.Constants.FiniteDifferenceType('CENTRAL'));
    end









    [obj.hasLB,obj.hasUB,obj.hasBounds]=...
    optim.coder.utils.hasFiniteBounds(obj.nVar,obj.hasLB,obj.hasUB,lb,ub,options);

end

