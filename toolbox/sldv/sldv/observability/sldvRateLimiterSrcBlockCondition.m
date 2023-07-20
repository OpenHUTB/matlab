function sldvRateLimiterSrcBlockCondition(blockH,condition,portIdx,label,offsetInCvgPts,outcome)






    coder.inline('always');
    coder.allowpcode('plain');



    numOfCvgPts=getNumberOfCoveragePoints(blockH);
    coverageType=getDecCvgString();
    outcome=cast(outcome,'double');

    sldvSrcBlockCondition(blockH,condition,portIdx,label,...
    coverageType,numOfCvgPts,offsetInCvgPts,outcome);
end
