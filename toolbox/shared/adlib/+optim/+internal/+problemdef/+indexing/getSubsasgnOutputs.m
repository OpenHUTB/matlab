function[outSize,outLinIdx,outIndexNames,outSubSize]=getSubsasgnOutputs(sub,exprSize,indexNames)

























    ExprIdx=sub(1).subs;
    nDims=numel(ExprIdx);


    exprSize=[exprSize,ones(1,nDims-numel(exprSize))];




    if(nDims==1)



        ExprLinIdx=ExprIdx{1};

        if isnumeric(ExprLinIdx)
            [outSize,outLinIdx,outIndexNames]=...
            getSubsasgnLinearNumericOutputs(ExprLinIdx,exprSize,indexNames);

        elseif islogical(ExprLinIdx)
            [outSize,outLinIdx,outIndexNames]=...
            getSubsasgnLinearLogicalOutputs(ExprLinIdx,exprSize,indexNames);

        elseif~(ischar(ExprLinIdx)||iscellstr(ExprLinIdx)||isstring(ExprLinIdx))

            throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));

        elseif numel(ExprLinIdx)==1&&strcmp(ExprLinIdx,':')

            outSize=exprSize;
            outLinIdx=(1:prod(exprSize))';
            outIndexNames=indexNames;

        else
            [outSize,outLinIdx,outIndexNames]=...
            getSubsasgnLinearStringOutputs(ExprLinIdx,exprSize,indexNames);

        end





        outSubSize=size(outLinIdx);

    elseif(nDims==numel(exprSize))

        [outSize,outLinIdx,outIndexNames,outSubSize]=...
        getSubsasgnNDIndexingOutputs(ExprIdx,exprSize,indexNames);

    else
        throwAsCaller(MException(message('shared_adlib:operators:InvalidIdx')));
    end

end
