function hiliteInfosMerged=mergeHiliteInfos(hiliteInfos)

    [traceBDs,~,ic]=unique([hiliteInfos.traceBD]);
    hiliteInfosMerged=[];

    for i=1:length(traceBDs)
        sameBDIndices=i==ic;
        hiliteInfosSameBD=hiliteInfos(sameBDIndices);
        hiliteInfosSameBD=mergeHiliteInfosWithSameBD(hiliteInfosSameBD);
        hiliteInfosMerged=[hiliteInfosMerged;hiliteInfosSameBD];
    end

end

function hiliteInfosMerged=mergeHiliteInfosWithSameBD(hiliteInfos)
    hiliteInfosMerged=hiliteInfos(1);
    graphHighlightMap=hiliteInfosMerged.graphHighlightMap;
    for i=2:length(hiliteInfos)
        rightMap=hiliteInfos(i).graphHighlightMap;
        graphHighlightMap=mergeHiliteMaps(graphHighlightMap,rightMap);
    end
    hiliteInfosMerged.graphHighlightMap=graphHighlightMap;
    hiliteInfosMerged.termGraphHandle=hiliteInfos(end).termGraphHandle;
end


function leftMap=mergeHiliteMaps(leftMap,rightMap)

    graphHandlesRight=[rightMap{:,1}];
    graphHandlesLeft=[leftMap{:,1}];

    for i=1:length(graphHandlesRight)
        graphHandle=graphHandlesRight(i);
        found=ismember(graphHandle,graphHandlesLeft);
        if(found)
            leftMap{found,2}=[leftMap{found,2},rightMap{i,2}];
        else
            leftMap(end+1,:)={graphHandle,[rightMap{i,2}]};
        end
    end
end