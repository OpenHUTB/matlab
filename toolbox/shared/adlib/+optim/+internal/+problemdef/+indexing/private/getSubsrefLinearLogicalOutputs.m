function[outSize,outLinIdx,outIndexNames]=getSubsrefLinearLogicalOutputs(ExprLinIdx,exprSize,indexNames)













    if all(size(ExprLinIdx)==0)


        outSize=[0,0];
        outLinIdx=[];
        outIndexNames={{},{}};
        return;
    end


    try
        checkIsValidLogicalIndex(ExprLinIdx,prod(exprSize));
    catch ME
        throwAsCaller(ME);
    end


    nsDim=exprSize~=1;

    linIdxSize=size(ExprLinIdx);

    nsDimIdx=linIdxSize~=1;

    numNsDim=sum(nsDim);


    ExprLinIdx=ExprLinIdx(:);

    if numNsDim<2























        outSize=exprSize;
        outIndexNames=indexNames;

        if numNsDim>0
            outSize(nsDim)=sum(ExprLinIdx);
            if~isempty(indexNames{nsDim})
                outIndexNames{nsDim}=indexNames{nsDim}(ExprLinIdx);
            end
        end

    elseif sum(ExprLinIdx)==1

        outSize=[1,1];

        outIndexNames=indexNames;
        nameIdx=cell(1,numel(exprSize));
        [nameIdx{:}]=ind2sub(exprSize,find(ExprLinIdx,1,'first'));
        nsDim=find(nsDim);
        for i=1:numNsDim
            curDim=nsDim(i);
            if~isempty(indexNames{curDim})
                outIndexNames{curDim}=outIndexNames{nsDim(i)}(nameIdx{curDim});
            end
        end

    elseif(sum(nsDimIdx)==1)








        outSize=linIdxSize;
        outSize(nsDimIdx)=sum(ExprLinIdx);



        outIndexNames=repmat({{}},1,numel(outSize));

    else




        outSize=[sum(ExprLinIdx),1];

        outIndexNames=repmat({{}},1,numel(outSize));
    end

    outLinIdx=find(ExprLinIdx);

end