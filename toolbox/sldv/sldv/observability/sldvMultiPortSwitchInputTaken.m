function expr=sldvMultiPortSwitchInputTaken(blockH,portIdx,isSingleDataInport,...
    vectorIdxInSingleInport,sizeOfSingleDataInport)



    coder.inline('never');
    coder.allowpcode('plain');


    numOfCvgPts=getNumberOfCoveragePoints(blockH);
    offsetInCvgPts=0;
    coverageType=getDecCvgString();

    if~isSingleDataInport
        controlPortSize=blockInportSize(blockH,1);
        outputExpr=true(controlPortSize,1);

        outcome=getOutcomeForMultiportSwitch(portIdx);
    else
        if vectorIdxInSingleInport==-1

            outputExpr=true(sizeOfSingleDataInport,1);
            outcome=-1;
        else
            outputExpr=true;
            outcome=vectorIdxInSingleInport-1;
        end
    end


    expr=sldv.getObjective(outputExpr,coder.const(outputExpr),...
    coder.const(coverageType),coder.const(numOfCvgPts),...
    coder.const(offsetInCvgPts),coder.const(outcome));
end
