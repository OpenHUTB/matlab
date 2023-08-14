function[outSize,outLinIdx,outIndexNames]=getSubsasgnDeleteLinearLogicalOutputs(ExprLinIdx,exprSize,indexNames)















    try
        checkIsValidLogicalIndex(ExprLinIdx,prod(exprSize));
    catch ME
        if strcmp(ME.identifier,'MATLAB:matrix:indexExceedsDims')
            throwAsCaller(MException(message('MATLAB:subsdeldimmismatch')));
        else
            rethrow(ME)
        end
    end


    nsDim=exprSize~=1;


    outLinIdx=find(ExprLinIdx');
    outIndexNames=indexNames;


    if(sum(nsDim)==1)








        outSize=exprSize;
        outSize(nsDim)=outSize(nsDim)-sum(ExprLinIdx);
        if~isempty(indexNames{nsDim})
            outIndexNames{nsDim}(ExprLinIdx)=[];
        end
    else







        outSize=[1,(prod(exprSize)-sum(ExprLinIdx))];
        outIndexNames={};
    end

end
