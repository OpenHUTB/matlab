function result=issimscapeblock(hBlock)
    blkType=get_param(hBlock,'BlockType');
    result=strcmp(blkType,'SimscapeBlock')||strcmp(blkType,'SimscapeComponentBlock')||strcmp(blkType,'SimscapeFaultBlock');
end
