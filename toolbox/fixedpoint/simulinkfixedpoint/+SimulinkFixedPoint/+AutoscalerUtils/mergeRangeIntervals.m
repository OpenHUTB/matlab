function mergedRanges=mergeRangeIntervals(inputRanges)










    [numRows,~]=size(inputRanges);
    inputRanges=sortrows(inputRanges,1);
    idx=1;
    mergedRanges(idx,:)=[inputRanges(1,1),inputRanges(1,2)];
    for i=2:numRows
        if mergedRanges(idx,2)<inputRanges(i,1)
            idx=idx+1;
            mergedRanges(idx,:)=[inputRanges(i,1),inputRanges(i,2)];
        elseif mergedRanges(idx,2)<inputRanges(i,2)
            mergedRanges(idx,2)=inputRanges(i,2);
        end
    end
    mergedRanges=mergedRanges(1:idx,:);
end