function addBlock(m2mObj,aBlkType,aBlkFullPath)



    if strcmpi(aBlkType,'PreLookup')||strcmpi(aBlkType,'Interpolation_n-D')
        add_block(['built-in/',aBlkType],[m2mObj.fPrefix,aBlkFullPath]);
    else
        add_block(aBlkType,[m2mObj.fPrefix,aBlkFullPath]);
    end
end
