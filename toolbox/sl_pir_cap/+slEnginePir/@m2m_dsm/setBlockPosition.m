function setBlockPosition(this,blkPath,refPath,gap,ori)






    while~strcmp(get_param(blkPath,'Parent'),get_param(refPath,'Parent'))
        refPath=get_param(blkPath,'Parent');
    end

    refPos=get_param(refPath,'Position');
    blkPos=get_param(blkPath,'Position');
    blkHeight=blkPos(4)-blkPos(2);
    blkWidth=blkPos(3)-blkPos(1);

    if ori=='r'
        srcCtrVer=(refPos(4)-refPos(2))/2+refPos(2);
        blkNewPos=[refPos(3)+gap,srcCtrVer-blkHeight/2,refPos(3)+gap+blkWidth,srcCtrVer+blkHeight/2];
    elseif ori=='l'
        srcCtrVer=(refPos(4)-refPos(2))/2+refPos(2);
        blkNewPos=[refPos(1)-gap-blkWidth,srcCtrVer-blkHeight/2,refPos(1)-gap,srcCtrVer+blkHeight/2];
    end
    set_param(blkPath,'Position',blkNewPos);

end
