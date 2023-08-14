function aggregateUniqueIds(this,srcCvd1,srcCvd2)





    cvdArray=[srcCvd1,srcCvd2];

    aggregatedIds={};



    for i=1:length(cvdArray)
        curAggIds=cvdArray(i).aggregatedIds;
        if~isempty(curAggIds)

            aggregatedIds=[aggregatedIds,curAggIds];%#ok<AGROW>
        else

            curUniqueId=cvdArray(i).uniqueId;
            if~isempty(curUniqueId)
                aggregatedIds=[aggregatedIds,{curUniqueId}];%#ok<AGROW>
            end
        end
    end
    this.aggregatedIds=unique(aggregatedIds,'stable');
