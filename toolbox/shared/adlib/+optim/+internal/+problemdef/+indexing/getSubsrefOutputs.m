function[outSize,outLinIdx,outIndexNames]=getSubsrefOutputs(sub,exprSize,indexNames)












































    ExprIdx=sub(1).subs;
    nDims=numel(ExprIdx);


    exprSize=[exprSize,ones(1,nDims-numel(exprSize))];

    if(nDims==1)



        ExprLinIdx=ExprIdx{1};

        if isnumeric(ExprLinIdx)
            [outSize,outLinIdx,outIndexNames]=...
            getSubsrefLinearNumericOutputs(ExprLinIdx,exprSize,indexNames);

        elseif islogical(ExprLinIdx)
            [outSize,outLinIdx,outIndexNames]=...
            getSubsrefLinearLogicalOutputs(ExprLinIdx,exprSize,indexNames);

        elseif~(ischar(ExprLinIdx)||iscellstr(ExprLinIdx)||isstring(ExprLinIdx))

            throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));

        elseif numel(ExprLinIdx)==1&&strcmp(ExprLinIdx,':')

            outSize=[prod(exprSize),1];
            outLinIdx=(1:prod(exprSize))';


            if numel(exprSize)==2&&any(exprSize==1)


                outIndexNames=indexNames;
                if exprSize(2)~=1


                    outIndexNames(1:2)={indexNames{2},indexNames{1}};
                end
            else

                outIndexNames=repmat({{}},1,numel(outSize));
            end

        else
            [outSize,outLinIdx,outIndexNames]=...
            getSubsrefLinearStringOutputs(ExprLinIdx,exprSize,indexNames);

        end

    elseif(nDims==numel(exprSize))

        [outSize,outLinIdx,outIndexNames]=...
        getSubsrefNDIndexingOutputs(ExprIdx,exprSize,indexNames);

    else
        throwAsCaller(MException(message('shared_adlib:operators:InvalidIdx')));
    end








    nout=numel(outSize);
    for i=nout:-1:2
        if(outSize(i)~=1)
            break;
        end
    end

    outSize(i+1:end)=[];

end
