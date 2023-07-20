function hiliteBlocks(blockPaths)





    blockPaths=strsplit(blockPaths,',');

    for i=1:length(blockPaths)
        hilite_system(blockPaths{i});
    end


