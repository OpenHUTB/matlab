function sldvForWhileIteratorSrcBlockCondition(blockH,condition,portIdx,label,isDecisionOnLoopCondition,outcome)


    coder.inline('always');
    coder.allowpcode('plain');

    numOfCvgPts=1;
    coverageType=getDecCvgString();
    outcome=cast(outcome,'double');

    if isDecisionOnLoopCondition
        offsetInCvgPts=0;
    else
        offsetInCvgPts=1;
    end

    sldvSrcBlockCondition(blockH,condition,portIdx,label,...
    coverageType,numOfCvgPts,offsetInCvgPts,outcome);
end
