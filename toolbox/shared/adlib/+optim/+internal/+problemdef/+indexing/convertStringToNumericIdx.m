function sub=convertStringToNumericIdx(sub,exprSize,indexNames)












    ExprIdx=sub(1).subs;
    nDims=numel(ExprIdx);
    nIdxNames=numel(indexNames);


    exprSize=[exprSize,ones(1,nDims-numel(exprSize))];

    if nDims==1

        ExprLinIdx=ExprIdx{1}(:)';


        if isnumeric(ExprLinIdx)

            try
                checkIsValidNumericIndex(ExprLinIdx,prod(exprSize));
            catch ME
                throwAsCaller(ME);
            end


        elseif islogical(ExprLinIdx)

            try
                checkIsValidLogicalIndex(ExprLinIdx,prod(exprSize));
            catch ME
                throwAsCaller(ME);
            end


        elseif~(ischar(ExprLinIdx)||iscellstr(ExprLinIdx)||isstring(ExprLinIdx))

            throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));

        elseif numel(ExprLinIdx)~=1||~strcmp(ExprLinIdx,':')
            if isempty(ExprLinIdx)
                ExprLinIdx=[];
            else




                if numel(exprSize)==2&&(exprSize(1)==1||exprSize(2)==1)

                    ExprLinIdx=cellstr(ExprLinIdx);

                    nsDim=find(exprSize~=1);

                    if isempty(nsDim)




                        if any(strcmp(ExprLinIdx{1},indexNames{2}))

                            nsDim=2;
                        else



                            nsDim=1;
                        end
                    end



                    for k=1:numel(ExprLinIdx)
                        if~any(strcmp(indexNames{nsDim},ExprLinIdx{k}))
                            throwAsCaller(MException(message('shared_adlib:operators:BadStringIdx',ExprLinIdx{k},nsDim)));
                        end
                    end




                    if isempty(nsDim)

                        ExprLinIdx=ones(numel(ExprLinIdx),1);
                    else
                        ExprLinIdx=arrayfun(@(name)find(strcmp(name,indexNames{nsDim}),1,'first'),ExprLinIdx);
                    end

                else

                    throwAsCaller(MException(message('shared_adlib:operators:BadLinStringIdx')));
                end
            end


            ExprIdx{1}=ExprLinIdx;
        end

    elseif(nDims==numel(exprSize))

        for i=1:nDims

            ExprIdxi=ExprIdx{i}(:)';

            if isnumeric(ExprIdxi)

                try
                    checkIsValidNumericIndex(ExprIdxi,exprSize(i),i);
                catch ME
                    throwAsCaller(ME);
                end

            elseif islogical(ExprIdxi)

                try
                    checkIsValidLogicalIndex(ExprIdxi,exprSize(i),i);
                catch ME
                    throwAsCaller(ME);
                end

            elseif~(ischar(ExprIdxi)||iscellstr(ExprIdxi)||isstring(ExprIdxi))

                throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));

            elseif numel(ExprIdxi)~=1||~strcmp(ExprIdxi,':')
                if isempty(ExprIdxi)
                    ExprIdxi=[];
                else

                    ExprIdxi=cellstr(ExprIdxi);
                    numExprIdxi=numel(ExprIdxi);
                    thisDimIdx=zeros(numExprIdxi,1);


                    if i>nIdxNames
                        throwAsCaller(MException(message('shared_adlib:operators:BadStringIdx',ExprIdxi{1},i)));
                    else

                        for k=1:numExprIdxi
                            thisDimIdxk=strcmp(ExprIdxi{k},indexNames{i});
                            if~any(thisDimIdxk)
                                throwAsCaller(MException(message('shared_adlib:operators:BadStringIdx',ExprIdxi{k},i)));
                            end
                            thisDimIdx(k)=find(thisDimIdxk,1,'first');
                        end
                        ExprIdxi=thisDimIdx;
                    end
                end
            end


            ExprIdx{i}=ExprIdxi;

        end

    else
        throwAsCaller(MException(message('shared_adlib:operators:InvalidIdx')));
    end

    sub(1).subs=ExprIdx;
