function sldvblkcov(blockH,expr,portIdx,conditionId)%#ok<INUSL>



















    coder.inline('always');
    coder.allowpcode('plain');



    if(nargin<4)
        conditionId=-1;
    else

        conditionId=cast(conditionId,'double');
    end
    sldv.observe(expr,coder.const(portIdx),coder.const(conditionId));

end
