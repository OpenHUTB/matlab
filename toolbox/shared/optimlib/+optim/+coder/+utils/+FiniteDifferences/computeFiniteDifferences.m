function[evalOK,gradf,JacCineqTrans,JacCeqTrans,xk,obj]=...
    computeFiniteDifferences(obj,fCurrent,cIneqCurrent,ineq0,cEqCurrent,eq0,...
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

    if(options.SpecifyConstraintGradient||obj.isEmptyNonlcon)&&...
        (options.SpecifyObjectiveGradient||isempty(obj.objfun))
        evalOK=true;
        return;
    end

    FORWARD=coder.const(optim.coder.utils.FiniteDifferences.Constants.FiniteDifferenceType('FORWARD'));

    switch(obj.FiniteDifferenceType)
    case FORWARD
        [evalOK,gradf,JacCineqTrans,JacCeqTrans,xk,obj]=...
        optim.coder.utils.FiniteDifferences.internal.computeForwardDifferences...
        (obj,fCurrent,cIneqCurrent,ineq0,cEqCurrent,eq0,...
        xk,gradf,JacCineqTrans,CineqColStart,ldJI,JacCeqTrans,CeqColStart,ldJE,...
        lb,ub,scales,options,runTimeOptions,varargin{:});
    otherwise
        [evalOK,gradf,JacCineqTrans,JacCeqTrans,xk,obj]=...
        optim.coder.utils.FiniteDifferences.internal.computeCentralDifferences...
        (obj,fCurrent,cIneqCurrent,ineq0,cEqCurrent,eq0,...
        xk,gradf,JacCineqTrans,CineqColStart,ldJI,JacCeqTrans,CeqColStart,ldJE,...
        lb,ub,scales,options,runTimeOptions,varargin{:});
    end

end

