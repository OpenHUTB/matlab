function[outSize,outLinIdx,outIndexNames]=getSubsrefNDIndexingOutputs(ExprIdx,exprSize,indexNames)














    nDims=numel(ExprIdx);

    nIdxNames=numel(indexNames);


    outSize=exprSize;

    outIndexNames=indexNames;

    dimIdx=cell(nDims,1);

    IsEmptyIndex=false;

    for i=1:nDims

        ExprIdxi=ExprIdx{i};

        if isnumeric(ExprIdxi)

            if isempty(ExprIdxi)
                outSize(i)=0;
                outIndexNames{i}={};
                IsEmptyIndex=true;
                continue;
            end


            try
                checkIsValidNumericIndex(ExprIdxi,exprSize(i),i);
            catch ME
                throwAsCaller(ME);
            end

            outSize(i)=numel(ExprIdxi);
            dimIdx{i}=ExprIdxi;
            if i<=nIdxNames&&~isempty(indexNames{i})
                outIndexNames{i}=indexNames{i}(ExprIdxi(:)');
            elseif numel(ExprIdxi)>1


                outIndexNames{i}={};
            end

        elseif islogical(ExprIdxi)

            if isempty(ExprIdxi)
                outSize(i)=0;
                outIndexNames{i}={};
                IsEmptyIndex=true;
                continue;
            end


            try
                checkIsValidLogicalIndex(ExprIdxi,exprSize(i),i);
            catch ME
                throwAsCaller(ME);
            end


            ExprIdxi=ExprIdxi(:);
            outSize(i)=sum(ExprIdxi);
            dimIdx{i}=find(ExprIdxi);
            if i<=nIdxNames&&~isempty(indexNames{i})
                outIndexNames{i}=indexNames{i}(ExprIdxi');


            end

        elseif~(ischar(ExprIdxi)||iscellstr(ExprIdxi)||isstring(ExprIdxi))

            throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));

        elseif numel(ExprIdxi)==1&&strcmp(ExprIdxi,':')


            dimIdx{i}=1:exprSize(i);


        else

            if isempty(ExprIdxi)
                outSize(i)=0;
                outIndexNames{i}={};
                IsEmptyIndex=true;
                continue;
            end


            ExprIdxi=cellstr(ExprIdxi);



            if i>nIdxNames
                throwAsCaller(MException(message('shared_adlib:operators:BadStringIdx',ExprIdxi{1},i)));
            else
                numExprIdxi=numel(ExprIdxi);
                thisDimIdx=zeros(numExprIdxi,1);

                for k=1:numExprIdxi
                    thisDimIdxk=strcmp(ExprIdxi{k},indexNames{i});
                    if~any(thisDimIdxk)
                        throwAsCaller(MException(message('shared_adlib:operators:BadStringIdx',ExprIdxi{k},i)));
                    end
                    thisDimIdx(k)=find(thisDimIdxk,1,'first');
                end
                outSize(i)=numExprIdxi;
                dimIdx{i}=thisDimIdx;
                outIndexNames{i}=ExprIdxi(:)';
            end

        end
    end




    if IsEmptyIndex
        outLinIdx=[];
    else
        outLinIdx=optim.internal.problemdef.indexing.nd2linidx(nDims,dimIdx,exprSize);
        outLinIdx=outLinIdx(:);
    end

end
