function blockPaths=spsGetFullBlockPath(blockHandles)




    blockPaths=getfullname(blockHandles);

    if~iscell(blockPaths)
        blockPaths={blockPaths};
    end

end