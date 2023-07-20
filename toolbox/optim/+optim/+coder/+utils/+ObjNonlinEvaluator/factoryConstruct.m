function obj=factoryConstruct(objfun,nonlcon,nVar,mCineq,mCeq,options)










































%#codegen

    coder.allowpcode('plain');




    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mCineq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mCeq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});






    coder.internal.prefer_const(objfun,nonlcon,nVar,mCineq,mCeq,options);




    obj=coder.internal.constantPreservingStruct(...
    'objfun',objfun,...
    'nonlcon',nonlcon,...
    'nVar',nVar,...
    'mCineq',mCineq,...
    'mCeq',mCeq,...
    'NonFiniteSupport',options.NonFiniteSupport,...
    'SpecifyObjectiveGradient',options.SpecifyObjectiveGradient,...
    'SpecifyConstraintGradient',options.SpecifyConstraintGradient,...
    'ScaleProblem',options.ScaleProblem);















end

