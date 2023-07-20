function sharedLists=gatherSharedDT(h,blkObj)



    sharedLists={};
    masktype=blkObj.MaskType;

    if strcmp(masktype,'2-D FFT')||...
        strcmp(masktype,'2-D IFFT')||...
        strcmp(masktype,'FFT')||...
        strcmp(masktype,'IFFT')
        sharedLists=hShareSrcAtSamePort(h,blkObj);
    end

