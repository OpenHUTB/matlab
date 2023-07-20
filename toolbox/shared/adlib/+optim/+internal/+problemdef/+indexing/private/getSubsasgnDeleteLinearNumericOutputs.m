function[outSize,outLinIdx,outIndexNames]=getSubsasgnDeleteLinearNumericOutputs(ExprLinIdx,exprSize,indexNames)






















    try
        checkIsValidNumericIndex(ExprLinIdx,prod(exprSize));
    catch ME
        if strcmp(ME.identifier,'MATLAB:matrix:indexExceedsDims')
            throwAsCaller(MException(message('MATLAB:subsdeldimmismatch')));
        else
            rethrow(ME)
        end
    end



    nsDim=exprSize~=1;


    outLinIdx=ExprLinIdx';
    outIndexNames=indexNames;


    if(sum(nsDim)==1)











        outSize=exprSize;
        outSize(nsDim)=outSize(nsDim)-numel(unique(ExprLinIdx));
        if~isempty(indexNames{nsDim})
            outIndexNames{nsDim}(ExprLinIdx)=[];
        end
    else







        outSize=[1,(prod(exprSize)-numel(unique(ExprLinIdx)))];
        outIndexNames=repmat({{}},1,numel(outSize));
    end