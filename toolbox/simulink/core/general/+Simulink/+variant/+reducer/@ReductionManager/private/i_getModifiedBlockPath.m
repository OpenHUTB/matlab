function blk=i_getModifiedBlockPath(blk,map)






    mdl=i_getRootBDNameFromPath(blk);

    if map.isKey(mdl)
        blk=[map(mdl),blk(numel(mdl)+1:end)];
    end
end
