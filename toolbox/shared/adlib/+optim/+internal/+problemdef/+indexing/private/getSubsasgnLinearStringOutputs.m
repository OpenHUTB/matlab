function[outSize,outLinIdx,outIndexNames]=getSubsasgnLinearStringOutputs(ExprLinIdx,exprSize,indexNames)














    if isempty(ExprLinIdx)

        outSize=exprSize;
        outLinIdx=[];
        outIndexNames=indexNames;
        return;
    end



    checkIsValidStringLinearIndexing(ExprLinIdx,exprSize,indexNames);





    ExprLinIdx=cellstr(ExprLinIdx);

    ExprLinIdx=ExprLinIdx(:);

    nsDim=find(exprSize~=1);




    uniqueExprLinIdx=optim.internal.problemdef.makeUniqueNames(ExprLinIdx);

    if numel(nsDim)==2

        outIndexNames={{},uniqueExprLinIdx};
        outSize=[1,numel(uniqueExprLinIdx)];
        outLinIdx=cellfun(@(name)find(strcmp(name,uniqueExprLinIdx),1,'first'),ExprLinIdx);
        return;
    end

    if isempty(nsDim)

        if~isempty(indexNames{1})&&all(strcmp(indexNames{1},uniqueExprLinIdx))


            outSize=exprSize;
            outIndexNames=indexNames;

            outLinIdx=ones(numel(ExprLinIdx),1);
            return;
        else


            nsDim=2;
        end
    end


    newIndexNames=~cellfun(@(name)any(strcmp(name,indexNames{nsDim})),uniqueExprLinIdx);
    outSize=exprSize;
    outSize(nsDim)=outSize(nsDim)+nnz(newIndexNames);
    outIndexNames=indexNames;
    outIndexNames{nsDim}=[outIndexNames{nsDim},uniqueExprLinIdx(newIndexNames)];
    outLinIdx=cellfun(@(name)find(strcmp(name,outIndexNames{nsDim}),1,'first'),ExprLinIdx);

end


function checkIsValidStringLinearIndexing(ExprLinIdx,exprSize,indexNames)

    if numel(exprSize)~=2||(~any(exprSize==1)&&~all(exprSize==0))


        throwAsCaller(MException(message('shared_adlib:operators:BadLinStringIdx')));
    end




    if exprSize(1)==1&&exprSize(2)~=0&&isempty(indexNames{2})

        throwAsCaller(MException(message('shared_adlib:operators:BadStringArrayGrowth',2)));
    elseif exprSize(2)==1&&exprSize(1)>1&&isempty(indexNames{1})

        throwAsCaller(MException(message('shared_adlib:operators:BadStringArrayGrowth',1)));
    end





    if any(string(ExprLinIdx)=="")
        throwAsCaller(MException(message('shared_adlib:operators:EmptyStringIndex')));
    end





    if any(string(ExprLinIdx)==":")
        throwAsCaller(MException(message('shared_adlib:operators:InvalidIndexName',':')));
    end
end