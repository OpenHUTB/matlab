function sldvDiscIntegExternetResetSrcBlockCondition(blockH,condition,portIdx,label,outcome)


    coder.inline('always');
    coder.allowpcode('plain');



    numOfCvgPts=1;
    coverageType=getDecCvgString();
    outcome=cast(outcome,'double');
    offsetInCvgPts=0;

    sldvSrcBlockCondition(blockH,condition,portIdx,label,...
    coverageType,numOfCvgPts,offsetInCvgPts,outcome);
end
