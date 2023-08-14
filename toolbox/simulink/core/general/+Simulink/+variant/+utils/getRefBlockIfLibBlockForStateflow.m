function blkPath=getRefBlockIfLibBlockForStateflow(blkPath)








    blkPath=getfullname(blkPath);
    if~strcmp('none',get_param(blkPath,'StaticLinkStatus'))
        blkPath=get_param(blkPath,'ReferenceBlock');
    end

end