function setBlockIcon(blkH,icon)





    maskObj=Simulink.Mask.get(blkH);
    maskObj.BlockDVGIcon=icon;
end