function subStr=getSubDisplay(linIdx,exprSize,indexNames,simplifySub)
















    if nargin<4




        simplifySub=true;
    end


    scalarDims=exprSize==1;

    if all(scalarDims)



        hasIdxNames=~cellfun(@isempty,indexNames);
        if any(hasIdxNames)

            indexNames(~hasIdxNames)={'1'};


            indexNames=string([indexNames{:}]);

            indexNames(hasIdxNames)="'"+indexNames(hasIdxNames)+"'";
            subStr="("+strjoin(indexNames,", ")+")";
        else
            subStr="";
        end


        subStr=repmat(subStr,numel(linIdx),1);
        return;
    elseif simplifySub&&sum(~scalarDims)==1&&(exprSize(1)>1||exprSize(2)>1)



        hasNoIdxNames=cellfun(@isempty,indexNames);
        if all(hasNoIdxNames(scalarDims))

            nsDimIdxNames=indexNames{~scalarDims};
            if~isempty(nsDimIdxNames)
                idxStr="'"+nsDimIdxNames(linIdx)+"'";
            else
                idxStr=string(linIdx);
            end
            subStr="("+idxStr(:)+")";
            return;
        end
    end


    nDims=numel(indexNames);
    subIdx=cell(1,nDims);
    [subIdx{:}]=ind2sub(exprSize,linIdx(:));


    subIdx=[subIdx{:}];

    nIdx=size(subIdx,1);


    subStr=strings(nIdx,nDims);
    for i=1:nDims
        if~isempty(indexNames{i})

            thisStr=indexNames{i}(subIdx(:,i));
            subStr(:,i)="'"+thisStr(:)+"'";
        else

            subStr(:,i)=string(subIdx(:,i));
        end
    end



    subStr="("+join(subStr,", ")+")";
end
