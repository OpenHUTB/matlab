function[outSize,outLinIdx,outIndexNames]=getSubsasgnLinearNumericOutputs(ExprLinIdx,exprSize,indexNames)














    if isempty(ExprLinIdx)

        outSize=exprSize;
        outLinIdx=[];
        outIndexNames=indexNames;
        return;
    end


    ExprLinIdx=ExprLinIdx(:);


    checkIsRealPositiveInteger(ExprLinIdx);



    outSize=exprSize;
    outLinIdx=ExprLinIdx;
    outIndexNames=indexNames;



    maxIdx=max(ExprLinIdx);
    outSize=getSubsasgnGrowLinearNumeric(maxIdx,outSize,indexNames);