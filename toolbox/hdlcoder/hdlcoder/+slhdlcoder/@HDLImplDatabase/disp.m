function disp(this)





    if~isempty(this.BlockDB)
        numBlocks=length(this.getBlockTags);
        numImpls=length(this.getDescriptionTags);
        sysObjIdxes=getSystemObjectIndices(this,this.getSupportedBlocks);
        numSysObjs=sum(sysObjIdxes);
        numBlocks=numBlocks-numSysObjs;
    else
        numBlocks=0;
        numImpls=0;
        numSysObjs=0;
    end

    disp(sprintf('    NumberOfSupportedBlocks: %d',numBlocks));
    disp(sprintf('    NumberOfImplementations: %d',numImpls));
    disp(sprintf('    NumberOfSupportedSystemObjects: %d',numSysObjs));
    disp(' ');
