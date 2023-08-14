function[iconFile,rotateIcon]=get_block_icon(blkType)




    iconFile='';
    rotateIcon=true;
    blkInfoMap=simmechanics.sli.internal.getTypeIdBlockInfoMap;
    if(blkInfoMap.isKey(blkType))
        blkInfo=blkInfoMap(blkType);
        iconFile=blkInfo.IconFile;
        slBlkProps=blkInfo.SLBlockProperties;
        rotateIcon=true;
        if strcmpi(slBlkProps.MaskIconRotate,'none')
            rotateIcon=true;
        end
    end

end