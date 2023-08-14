function sldvMultiportSwitchSrcBlockCondition(blockH,condition,portIdx,label,...
    isSingleDataInport,vectIdxInSingleDataInport)





    coder.inline('always');
    coder.allowpcode('plain');


    numOfCvgPts=getNumberOfCoveragePoints(blockH);
    offsetInCvgPts=0;
    coverageType=getDecCvgString();

    if~isSingleDataInport
        outcome=getOutcomeForMultiportSwitch(portIdx);
    else
        outcome=vectIdxInSingleDataInport-1;
    end

    sldvSrcBlockCondition(blockH,condition,portIdx,label,...
    coverageType,numOfCvgPts,offsetInCvgPts,outcome);
end
