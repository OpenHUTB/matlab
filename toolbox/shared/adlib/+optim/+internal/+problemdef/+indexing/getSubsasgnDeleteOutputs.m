function[outSize,outLinIdx,outIndexNames]=getSubsasgnDeleteOutputs(sub,exprSize,indexNames)
























    ExprIdx=sub(1).subs;
    nDims=numel(ExprIdx);


    exprSize=[exprSize,ones(1,nDims-numel(exprSize))];




    if(nDims==1)



        ExprLinIdx=ExprIdx{1}(:)';

        if isnumeric(ExprLinIdx)
            [outSize,outLinIdx,outIndexNames]=...
            getSubsasgnDeleteLinearNumericOutputs(ExprLinIdx,exprSize,indexNames);

        elseif islogical(ExprLinIdx)
            [outSize,outLinIdx,outIndexNames]=...
            getSubsasgnDeleteLinearLogicalOutputs(ExprLinIdx,exprSize,indexNames);

        elseif~(ischar(ExprLinIdx)||iscellstr(ExprLinIdx)||isstring(ExprLinIdx))

            throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));

        elseif numel(ExprLinIdx)==1&&strcmp(ExprLinIdx,':')

            outSize=[0,0];
            outLinIdx=(1:prod(exprSize))';
            outIndexNames={{},{}};

        else
            [outSize,outLinIdx,outIndexNames]=...
            getSubsasgnDeleteLinearStringOutputs(ExprLinIdx,exprSize,indexNames);

        end

    elseif(nDims==numel(exprSize))

        [outSize,outLinIdx,outIndexNames]=...
        getSubsasgnDeleteNDIndexingOutputs(ExprIdx,exprSize,indexNames);

    else
        throwAsCaller(MException(message('shared_adlib:operators:InvalidIdx')));
    end

end
