function[outSize,outLinIdx,outIndexNames]=getSubsasgnLinearLogicalOutputs(ExprLinIdx,exprSize,indexNames)














    if isempty(ExprLinIdx)

        outSize=exprSize;
        outLinIdx=[];
        outIndexNames=indexNames;
        return;
    end


    ExprLinIdx=ExprLinIdx(:);


    outSize=exprSize;
    outLinIdx=find(ExprLinIdx);
    outIndexNames=indexNames;



    maxIdx=outLinIdx(end);
    outSize=getSubsasgnGrowLinearNumeric(maxIdx,outSize,indexNames);