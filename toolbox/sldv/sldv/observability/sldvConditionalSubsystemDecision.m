function expr=sldvConditionalSubsystemDecision(blockH,outcome)



    coder.inline('never');
    coder.allowpcode('plain');

    exprSize=1;
    outputExpr=true(exprSize,1);



    numOfCvgPts=1;
    offsetInCvgPts=0;
    coverageType=getDecCvgString();
    outcome=cast(outcome,'double');


    expr=sldv.getObjective(outputExpr,coder.const(outputExpr),...
    coder.const(coverageType),coder.const(numOfCvgPts),...
    coder.const(offsetInCvgPts),coder.const(outcome));
end
