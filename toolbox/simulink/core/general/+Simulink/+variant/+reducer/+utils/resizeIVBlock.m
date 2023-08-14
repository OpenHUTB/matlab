function resizeIVBlock(variantBlock,nSegments,nSegmentsToRetain)









    orgPos=get_param(variantBlock,'Position');
    blkLen=orgPos(4)-orgPos(2);
    newBlkLen=blkLen*nSegmentsToRetain/nSegments;
    diffLen=(blkLen-newBlkLen)/2;
    orgPos(2)=floor(orgPos(2)+diffLen);
    orgPos(4)=ceil(orgPos(4)-diffLen);
    set_param(variantBlock,'Position',orgPos);

end
