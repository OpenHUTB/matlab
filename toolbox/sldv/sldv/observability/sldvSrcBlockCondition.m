
































function sldvSrcBlockCondition(blockH,expr,portIdx,label,...
    covType,numOfCvgPts,offsetInCvgPt,outcome)%#ok<INUSL>

    coder.inline('always');
    coder.allowpcode('plain');

    blockType=0;

    if(nargin<4)
        label='';
    end

    if nargin<5
        covType='';
        numOfCvgPts=-1;
        offsetInCvgPt=-1;
        outcome=-1;
    end


    sldv.observe(expr,coder.const(portIdx),coder.const(blockType),...
    coder.const(label),coder.const(covType),coder.const(numOfCvgPts),...
    coder.const(offsetInCvgPt),coder.const(outcome));
end
