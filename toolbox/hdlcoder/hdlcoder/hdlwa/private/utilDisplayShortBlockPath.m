function blkShortName=utilDisplayShortBlockPath(blkFullName)












    blkShortName=blkFullName;

    idx=regexp(blkFullName,'[^/]/[^/]');
    if~isempty(idx)&&length(idx)~=1
        blkShortName=['...',blkFullName(idx(end-1)+1:end)];
    end
