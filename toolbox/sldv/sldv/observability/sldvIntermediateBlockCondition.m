function sldvIntermediateBlockCondition(blockH,expr,portIdx,label)%#ok<INUSL>

















    coder.inline('always');
    coder.allowpcode('plain');

    if(nargin<4)
        label='';
    end

    blockType=1;


    covType='';
    numOfCvgPts=-1;
    offsetInCvgPt=-1;
    outcome=-1;


    sldv.observe(expr,coder.const(portIdx),coder.const(blockType),...
    coder.const(label),coder.const(covType),coder.const(numOfCvgPts),...
    coder.const(offsetInCvgPt),coder.const(outcome));
end
