function[outSize,outLinIdx,outIndexNames]=getSubsasgnDeleteNDIndexingOutputs(ExprIdx,exprSize,indexNames)















    nDims=numel(ExprIdx);

    nIdxNames=numel(indexNames);

    idxNonColon=~strcmp(ExprIdx,":");
    numNonColon=sum(idxNonColon);


    outSize=exprSize;
    outIndexNames=indexNames;


    if numNonColon>1
        throwAsCaller(MException(message('MATLAB:badnullassign')));

    elseif numNonColon>0


        ExprIdxi=ExprIdx{idxNonColon}(:)';


        dimIdx=arrayfun(@(sizei)1:sizei,exprSize,'UniformOutput',false);

        if isnumeric(ExprIdxi)

            if isempty(ExprIdxi)

                outLinIdx=[];
                return;
            end

            try
                checkIsValidNumericIndex(ExprIdxi,exprSize(idxNonColon),idxNonColon);
            catch ME
                if strcmp(ME.identifier,'MATLAB:matrix:indexExceedsDims')
                    throwAsCaller(MException(message('MATLAB:subsdeldimmismatch')));
                else
                    rethrow(ME)
                end
            end

            ExprIdxi=unique(ExprIdxi);
            numIdx=numel(ExprIdxi);
            outSize(idxNonColon)=outSize(idxNonColon)-numIdx;
            dimIdx{idxNonColon}=ExprIdxi;
            if nDims>nIdxNames&&any(idxNonColon(nIdxNames+1:end))
                outIndexNames{idxNonColon}={};
            elseif~isempty(indexNames{idxNonColon})
                outIndexNames{idxNonColon}(ExprIdxi)=[];
            end

        elseif islogical(ExprIdxi)

            if isempty(ExprIdxi)

                outLinIdx=[];
                return;
            end

            try
                checkIsValidLogicalIndex(ExprIdxi,exprSize(idxNonColon),idxNonColon);
            catch ME
                if strcmp(ME.identifier,'MATLAB:matrix:indexExceedsDims')
                    throwAsCaller(MException(message('MATLAB:subsdeldimmismatch')));
                else
                    rethrow(ME)
                end
            end

            numIdx=sum(ExprIdxi);
            outSize(idxNonColon)=outSize(idxNonColon)-numIdx;
            dimIdx{idxNonColon}=find(ExprIdxi);
            if nDims>nIdxNames&&any(idxNonColon(nIdxNames+1:end))
                outIndexNames{idxNonColon}={};
            elseif~isempty(indexNames{idxNonColon})
                outIndexNames{idxNonColon}(ExprIdxi)=[];
            end

        elseif~(ischar(ExprIdxi)||iscellstr(ExprIdxi)||isstring(ExprIdxi))

            throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));

        else

            if isempty(ExprIdxi)

                outLinIdx=[];
                return;
            end


            ExprIdxi=cellstr(ExprIdxi);
            ExprIdxi=optim.internal.problemdef.makeUniqueNames(ExprIdxi);



            idxNonColon=find(idxNonColon);
            if idxNonColon>nIdxNames
                throwAsCaller(MException(message('shared_adlib:operators:BadStringIdx',ExprIdxi{1},idxNonColon)));
            else
                numExprIdxi=numel(ExprIdxi);
                thisDimIdx=zeros(numel(ExprIdxi),1);

                for k=1:numExprIdxi
                    thisDimIdxk=strcmp(ExprIdxi{k},indexNames{idxNonColon});
                    if~any(thisDimIdxk)
                        throwAsCaller(MException(message('shared_adlib:operators:BadStringIdx',ExprIdxi{k},idxNonColon)));
                    end
                    thisDimIdx(k)=find(thisDimIdxk,1,'first');
                end
            end

            numIdx=numel(ExprIdxi);
            outSize(idxNonColon)=outSize(idxNonColon)-numIdx;
            dimIdx{idxNonColon}=thisDimIdx;
            idxDelete=cellfun(@(name)find(strcmp(name,indexNames{idxNonColon}),1,'first'),ExprIdxi);
            outIndexNames{idxNonColon}(idxDelete)=[];
        end

        outLinIdx=optim.internal.problemdef.indexing.nd2linidx(numel(ExprIdx),dimIdx,exprSize);
        outLinIdx=outLinIdx(:);

    else









        outSize=exprSize;
        outSize(1)=0;
        outLinIdx=(1:prod(exprSize))';

        outIndexNames{1}={};
    end
