function blkPath=getBlockPathWithoutNewLines(blkHandle)





    assert(blkHandle>0,"Invalid block handle");
    blkPath=getfullname(blkHandle);
    blkPath=Simulink.variant.utils.replaceNewLinesWithSpaces(blkPath);
end
