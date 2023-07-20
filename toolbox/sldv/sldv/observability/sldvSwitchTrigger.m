












function expr=sldvSwitchTrigger(blockH,outcome)

    coder.inline('never');
    coder.allowpcode('plain');







    triggerSize=blockInportSize(blockH,2);
    outputExpr=true(triggerSize,1);

    numOfCvgPts=getNumberOfCoveragePoints(blockH);
    offsetInCvgPts=0;


    coverageType=getDecCvgString();
    outcome=cast(outcome,'double');


    expr=sldv.getObjective(outputExpr,coder.const(outputExpr),...
    coder.const(coverageType),coder.const(numOfCvgPts),...
    coder.const(offsetInCvgPts),coder.const(outcome));
end
