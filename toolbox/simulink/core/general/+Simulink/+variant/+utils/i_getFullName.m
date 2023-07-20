
function blockNames=i_getFullName(blockHandles)

    blockNames=getfullname(blockHandles);
    if~isa(blockNames,'cell')

        blockNames={blockNames};
    end
end