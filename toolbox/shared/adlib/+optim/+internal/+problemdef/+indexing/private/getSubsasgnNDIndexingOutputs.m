function[outSize,outLinIdx,outIndexNames,sizeIdx]=getSubsasgnNDIndexingOutputs(ExprIdx,exprSize,indexNames)














    nDims=numel(ExprIdx);

    nIdxNames=numel(indexNames);


    outSize=exprSize;

    outIndexNames=indexNames;


    dimIdx=cell(nDims,1);
    sizeIdx=zeros(1,nDims);

    IsEmptyIndex=false;

    for i=1:nDims



        ExprIdxi=ExprIdx{i}(:)';

        if isnumeric(ExprIdxi)
            if isempty(ExprIdxi)

                sizeIdx(i)=0;
                IsEmptyIndex=true;
                continue;
            end


            checkIsRealPositiveInteger(ExprIdxi,i);






            if any(ExprIdxi>exprSize(i))&&i<=nIdxNames&&~isempty(indexNames{i})
                throwAsCaller(MException(message('shared_adlib:operators:BadNumericArrayGrowth',i)));
            end


            maxIdx=max(ExprIdxi);
            if maxIdx>exprSize(i)
                outSize(i)=maxIdx;
            end
            dimIdx{i}=ExprIdxi;
            sizeIdx(i)=numel(ExprIdxi);


            if i>nIdxNames
                outIndexNames{i}={};
            end

        elseif islogical(ExprIdxi)
            if isempty(ExprIdxi)

                sizeIdx(i)=0;
                IsEmptyIndex=true;
                continue;
            end



            if(find(ExprIdxi,1,'last')>exprSize(i))&&i<=nIdxNames&&~isempty(indexNames{i})
                throwAsCaller(MException(message('shared_adlib:operators:BadNumericArrayGrowth',i)));
            end


            maxIdx=find(ExprIdxi,1,'last');
            if maxIdx>exprSize(i)
                outSize(i)=maxIdx;
            end
            dimIdx{i}=find(ExprIdxi);
            sizeIdx(i)=numel(dimIdx{i});


            if i>nIdxNames
                outIndexNames{i}={};
            end

        elseif~(ischar(ExprIdxi)||iscellstr(ExprIdxi)||isstring(ExprIdxi))

            throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));

        elseif numel(ExprIdxi)==1&&strcmp(ExprIdxi,':')

            dimIdx{i}=1:exprSize(i);
            sizeIdx(i)=exprSize(i);

        else
            if isempty(ExprIdxi)

                sizeIdx(i)=0;
                IsEmptyIndex=true;
                continue;
            end


            if(i>nIdxNames||isempty(indexNames{i}))&&exprSize(i)~=0
                throwAsCaller(MException(message('shared_adlib:operators:BadStringArrayGrowth',i)));
            end





            if any(string(ExprIdxi)=="")
                throwAsCaller(MException(message('shared_adlib:operators:EmptyStringIndex')));
            end





            if any(string(ExprIdxi)==":")
                throwAsCaller(MException(message('shared_adlib:operators:InvalidIndexName',':')));
            end


            ExprIdxi=cellstr(ExprIdxi);


            uniqueExprIdxi=optim.internal.problemdef.makeUniqueNames(ExprIdxi);
            newIndexNames=~cellfun(@(name)any(strcmp(name,indexNames{i})),uniqueExprIdxi);
            outSize(i)=outSize(i)+nnz(newIndexNames);

            outIndexNames{i}=[outIndexNames{i},uniqueExprIdxi(newIndexNames)];
            dimIdx{i}=cellfun(@(name)find(strcmp(name,outIndexNames{i}),1,'first'),ExprIdxi);
            sizeIdx(i)=numel(ExprIdxi);

        end
    end




    if IsEmptyIndex
        outLinIdx=[];
    else
        outLinIdx=optim.internal.problemdef.indexing.nd2linidx(nDims,dimIdx,outSize);
        outLinIdx=outLinIdx(:);
    end









    nout=numel(sizeIdx);
    for i=nout:-1:2
        if(sizeIdx(i)~=1)
            break;
        end
    end

    sizeIdx(i+1:end)=[];

end
