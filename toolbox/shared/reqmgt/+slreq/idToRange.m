












function range=idToRange(srcUri,id)

    range=rmiml.idToRange(srcUri,id);

    if isempty(range)
        rmiut.warnNoBacktrace('Slvnv:rmiml:UnmatchedID',id);

    elseif range(2)==0
        rmiut.warnNoBacktrace('Slvnv:rmiml:BookmarkIsDeleted',id,srcUri);
    end

end


