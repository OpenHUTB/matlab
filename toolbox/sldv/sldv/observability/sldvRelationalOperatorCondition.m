function expr=sldvRelationalOperatorCondition(blockH,outcome)





    coder.inline('never');
    coder.allowpcode('plain');

    outportDims=blockOutportSize(blockH);
    outputExpr=true(prod(outportDims),1);



    numOfCvgPts=getNumberOfCoveragePoints(blockH);
    offsetInCvgPts=0;



    coverageType=getConditionCvgString();
    outcome=cast(outcome,'double');


    expr=sldv.getObjective(outputExpr,...
    coder.const(outputExpr),...
    coder.const(coverageType),coder.const(numOfCvgPts),...
    coder.const(offsetInCvgPts),coder.const(outcome));
end
