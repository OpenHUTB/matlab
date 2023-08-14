function expr=sldvMinMaxInputTaken(blockH,portIdx,isSingleInport,...
    vectorIdxInSingleInport,sizeOfSingleInport)












    coder.inline('never');
    coder.allowpcode('plain');

    if~isSingleInport






        outportDims=blockOutportSize(blockH);
        outputExpr=true(prod(outportDims),1);
        outcome=getOutcomeForMinMax(portIdx);

    else
        if vectorIdxInSingleInport==-1

            outputExpr=true(sizeOfSingleInport,1);
            outcome=-1;
        else
            outputExpr=true;

            outcome=getOutcomeForMinMax(vectorIdxInSingleInport);
        end
    end

    numOfCvgPts=getNumberOfCoveragePoints(blockH);
    offsetInCvgPts=0;


    coverageType=getDecCvgString();


    expr=sldv.getObjective(outputExpr,coder.const(outputExpr),...
    coder.const(coverageType),coder.const(numOfCvgPts),...
    coder.const(offsetInCvgPts),coder.const(outcome));
end
