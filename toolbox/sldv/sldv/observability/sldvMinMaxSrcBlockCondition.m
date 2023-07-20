function sldvMinMaxSrcBlockCondition(blockH,condition,portIdx,label,...
    isSingleInport,vectIdxInSingleInport)


    coder.inline('always');
    coder.allowpcode('plain');



    numOfCvgPts=getNumberOfCoveragePoints(blockH);
    offsetInCvgPts=0;
    coverageType=getDecCvgString();

    if~isSingleInport
        outcome=getOutcomeForMinMax(portIdx);
    else
        outcome=getOutcomeForMinMax(vectIdxInSingleInport);
    end

    sldvSrcBlockCondition(blockH,condition,portIdx,label,...
    coverageType,numOfCvgPts,offsetInCvgPts,outcome);
end
