function[augJacobian,fCurrent,funcCount,evalOK,FiniteDifferences]=jacobianFiniteDifference(augJacobian,fCurrent,funcCount,x,lb,ub,options,TypicalX,FiniteDifferences,runTimeOptions)












































%#codegen

    eml_allow_mx_inputs;
    coder.allowpcode('plain');
    coder.internal.prefer_const(augJacobian,fCurrent,funcCount,x,lb,ub,options,TypicalX,FiniteDifferences,runTimeOptions);

    validateattributes(fCurrent,{'double'},{'2d'});
    m=coder.internal.indexInt(numel(fCurrent));
    validateattributes(funcCount,{coder.internal.indexIntClass},{'scalar'});

    n=coder.internal.indexInt(numel(x));
    validateattributes(augJacobian,{'double'},{'size',[m+n,n]});
    validateattributes(lb,{'double'},{'column'});
    validateattributes(ub,{'double'},{'column'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(TypicalX,{'double'},{'size',[n,1]});
    validateattributes(FiniteDifferences,{'struct'},{'scalar'});

    intZero=coder.internal.indexInt(0);
    intOne=coder.internal.indexInt(1);
    JacCeqTrans=coder.nullcopy(zeros(n,m));
    scales=struct('objective',[],'cineq_constraint',[],'ceq_constraint',[]);






    finiteDifferenceOptions=struct(...
    'SpecifyObjectiveGradient',options.SpecifyObjectiveGradient,...
    'SpecifyConstraintGradient',options.SpecifyConstraintGradient,...
    'NonFiniteSupport',options.NonFiniteSupport,...
    'ScaleProblem',false);

    [evalOK,~,~,JacCeqTrans,~,FiniteDifferences]=...
    optim.coder.utils.FiniteDifferences.computeFiniteDifferences(...
    FiniteDifferences,0,[],intOne,fCurrent,intOne,...
    x,[],[],intOne,intZero,...
    JacCeqTrans,intOne,n,...
    lb,ub,scales,finiteDifferenceOptions,runTimeOptions);

    if strcmpi(options.FiniteDifferenceType,'forward')
        funcCount=funcCount+FiniteDifferences.numEvals;
    elseif strcmpi(options.FiniteDifferenceType,'central')
        funcCount=funcCount+FiniteDifferences.numEvals;
    end
    augJacobian(1:m,:)=JacCeqTrans';

end
