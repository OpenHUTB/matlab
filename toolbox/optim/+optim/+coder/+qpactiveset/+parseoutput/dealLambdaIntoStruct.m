function[lambda,solution]=dealLambdaIntoStruct(lambda,solution,WorkingSet)
























%#codegen

    coder.allowpcode('plain');

    validateattributes(lambda,{'struct'},{'scalar'});
    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));


    offset=WorkingSet.isActiveIdx(FIXED);
    for idx=offset:WorkingSet.isActiveIdx(AEQ)-1
        lambda.lower(WorkingSet.indexFixed(idx))=solution.lambda(idx);
        lambda.upper(WorkingSet.indexFixed(idx))=solution.lambda(idx);
    end


    offset=WorkingSet.isActiveIdx(AEQ);
    for idx=offset:WorkingSet.isActiveIdx(AINEQ)-1
        lambda.eqlin(idx-offset+1)=solution.lambda(idx);
    end




    offset=WorkingSet.isActiveIdx(AINEQ);
    for idx=offset:WorkingSet.isActiveIdx(LOWER)-1
        lambda.ineqlin(idx-offset+1)=solution.lambda(idx);
    end

    offset=WorkingSet.isActiveIdx(LOWER);
    for idx=offset:WorkingSet.isActiveIdx(UPPER)-1
        lowerIdx=WorkingSet.indexLB(idx-offset+1);
        lambda.lower(lowerIdx)=solution.lambda(idx);
    end

    offset=WorkingSet.isActiveIdx(UPPER);
    for idx=offset:WorkingSet.isActiveIdx(end)-1
        lowerIdx=WorkingSet.indexUB(idx-offset+1);
        lambda.upper(lowerIdx)=solution.lambda(idx);
    end

end

