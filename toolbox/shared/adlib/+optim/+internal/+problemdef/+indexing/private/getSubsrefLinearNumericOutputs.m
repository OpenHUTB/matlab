function[outSize,outLinIdx,outIndexNames]=getSubsrefLinearNumericOutputs(ExprLinIdx,exprSize,indexNames)















    if isempty(ExprLinIdx)
        outSize=size(ExprLinIdx);
        outLinIdx=[];
        outIndexNames=repmat({{}},1,numel(outSize));
        return;
    end



    try
        checkIsValidNumericIndex(ExprLinIdx,prod(exprSize));
    catch ME
        throwAsCaller(ME);
    end


    nsDim=exprSize~=1;

    exprLinIdxSize=size(ExprLinIdx);

    nsDimIdx=exprLinIdxSize~=1;

    numNsDim=sum(nsDim);

    numNsDimIdx=sum(nsDimIdx);


    ExprLinIdx=ExprLinIdx(:);

    if numNsDim==0









        outSize=exprLinIdxSize;


        outIndexNames=indexNames;
        nsDimIdx=find(nsDimIdx);
        nIdxNames=numel(outIndexNames);
        for i=nsDimIdx

            if i<=nIdxNames&&~isempty(outIndexNames{i})

                outIndexNames{i}=outIndexNames{i}(ones(1,outSize(i)));
            else

                outIndexNames{i}={};
            end
        end
    else

        if(numNsDim==1)&&(numNsDimIdx==1)








            outSize=exprSize;
            outSize(nsDim)=numel(ExprLinIdx);
            outIndexNames=indexNames;
            if~isempty(indexNames{nsDim})
                outIndexNames{nsDim}=indexNames{nsDim}(ExprLinIdx);
            end

        elseif(numNsDim==1)&&(numNsDimIdx==0)


            outSize=exprLinIdxSize;

            outIndexNames=indexNames;
            if~isempty(indexNames{nsDim})
                outIndexNames{nsDim}=indexNames{nsDim}(ExprLinIdx);
            end

        else











            outSize=exprLinIdxSize;
            if numNsDimIdx==0

                outIndexNames=indexNames;
                nameIdx=cell(1,numel(exprSize));
                [nameIdx{:}]=ind2sub(exprSize,ExprLinIdx);
                nsDim=find(nsDim);
                for i=1:numNsDim
                    curDim=nsDim(i);
                    if~isempty(indexNames{curDim})
                        outIndexNames{curDim}=outIndexNames{nsDim(i)}(nameIdx{curDim});
                    end
                end
            else

                outIndexNames=repmat({{}},1,numel(outSize));
            end
        end
    end

    outLinIdx=ExprLinIdx;
