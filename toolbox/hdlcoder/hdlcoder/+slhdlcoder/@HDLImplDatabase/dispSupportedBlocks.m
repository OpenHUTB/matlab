function dispSupportedBlocks(this)







    blocks=this.getSupportedBlocks;


    blocks=regexprep(blocks,'\n',' ');

    sysObjIdxes=getSystemObjectIndices(this,blocks);

    disp(' ')
    disp('Supported blocks:')
    disp(' ')
    disp(blocks(~sysObjIdxes))

    disp(' ')
    disp('Supported System objects:')
    disp(' ')
    disp(blocks(sysObjIdxes))
