function sortedReqs=sortByIndex(dasReqs)

    paddedIndex=arrayfun(@(x)getPaddedIndex(x),dasReqs,'UniformOutput',false);
    [~,sortedIdx]=sort(paddedIndex);
    sortedReqs=dasReqs(sortedIdx);

    function out=getPaddedIndex(in)


        idxStr=in.Index;
        idxCell=strsplit(idxStr,'.');
        out='';
        for n=1:length(idxCell)
            thisLevel=sprintf('%06d',str2double(idxCell{n}));
            out=[out,num2str(thisLevel)];%#ok<AGROW>
        end
    end
end

