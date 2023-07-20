function childIndices=getChildIndices(parentIdx,nodeIsIncluded)
    childIndices=[];
    startInds=find(nodeIsIncluded);
    lastIdx=length(parentIdx);
    for i=startInds'
        pvalue=parentIdx(i);
        cIdx=i+1;
        while cIdx<=lastIdx&&parentIdx(cIdx)>pvalue
            childIndices(end+1)=cIdx;%#ok<AGROW>
            cIdx=cIdx+1;
        end
    end
end
