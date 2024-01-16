function drawBlockFromUser(this,tgtParentPath,hC)
    blkname=hC.getPropertyValueString('Name');
    slBlockName=hdlfixblockname(['',tgtParentPath,'/',blkname,'']);

    drawRTWCGBlock(this,slBlockName,hC);
end