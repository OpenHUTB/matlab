function sldvAbsSrcBlockCondition(blockH,condition,portIdx,label,outcome)






    coder.inline('always');
    coder.allowpcode('plain');



    numOfCvgPts=getNumberOfCoveragePoints(blockH);
    offsetInCvgPts=0;
    coverageType=getDecCvgString();
    outcome=cast(outcome,'double');

    sldvSrcBlockCondition(blockH,condition,portIdx,label,...
    coverageType,numOfCvgPts,offsetInCvgPts,outcome);
end
