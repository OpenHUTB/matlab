function expr=sldvLogicConditionInput(blockH,portIdx,outcome,isSingleInport,...
    vectorIdxInSingleInport)
















    coder.inline('never');
    coder.allowpcode('plain');




















    numOfCvgPts=getNumberOfCoveragePoints(blockH);
    outcome=cast(outcome,'double');
    coverageType=getConditionCvgString();


    if~isSingleInport
        portSize=blockInportSize(blockH,portIdx);
        outputExpr=true(portSize,1);


        offsetInCvgPts=getOffsetInCoveragePointsForLogicBlock(blockH,portIdx);
    else


        outputExpr=true;
        offsetInCvgPts=vectorIdxInSingleInport-1;
    end


    expr=sldv.getObjective(outputExpr,coder.const(outputExpr),...
    coder.const(coverageType),coder.const(numOfCvgPts),...
    coder.const(offsetInCvgPts),coder.const(outcome));

end
