function out=replaceOrigRootWithSyntRootIOBlock(sortedBlks)





    origRootToSyntRootIOBlockMap=slci.internal.getOrigRootToSyntRootIOBlockMap(sortedBlks);
    if isempty(origRootToSyntRootIOBlockMap)
        out=sortedBlks;
        return;
    end
    out=setdiff(sortedBlks,cell2mat(keys(origRootToSyntRootIOBlockMap)));
    out=vertcat(out,cell2mat(values(origRootToSyntRootIOBlockMap))');
end

