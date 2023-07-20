

function expr=sldvForWhileIteratorDecision(blockH,outcome,isDecisionOnLoopCondition)%#ok<INUSL>

    coder.inline('never');
    coder.allowpcode('plain');

    outputExpr=true(1,1);

    numOfCvgPts=1;
    coverageType=getDecCvgString();
    outcome=cast(outcome,'double');
    if isDecisionOnLoopCondition
        offsetInCvgPts=0;
    else
        offsetInCvgPts=1;
    end


    expr=sldv.getObjective(outputExpr,coder.const(outputExpr),...
    coder.const(coverageType),coder.const(numOfCvgPts),...
    coder.const(offsetInCvgPts),coder.const(outcome));
end
