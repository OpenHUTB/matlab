function sldvLogicSrcBlockCondition(blockH,condition,portIdx,label,outcome,...
    isSingleInport,vectorIdxInSingleInport)






    coder.inline('always');
    coder.allowpcode('plain');



    numOfCvgPts=getNumberOfCoveragePoints(blockH);
    if~isSingleInport

        offsetInCvgPts=getOffsetInCoveragePointsForLogicBlock(blockH,portIdx);
    else


        offsetInCvgPts=vectorIdxInSingleInport-1;
    end
    coverageType=getConditionCvgString();
    outcome=cast(outcome,'double');

    sldvSrcBlockCondition(blockH,condition,portIdx,label,...
    coverageType,numOfCvgPts,offsetInCvgPts,outcome);
end
