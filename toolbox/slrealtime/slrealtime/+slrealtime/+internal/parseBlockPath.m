function indices=parseBlockPath(blockpathStr)




















    indices=regexp(blockpathStr,'[^/]/[^/]');
    if~isempty(indices)
        indices=indices+1;
    end
