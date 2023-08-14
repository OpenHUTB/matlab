function result=islibraryblock(hBlock)
    blkType=get_param(hBlock,'BlockType');
    result=strcmp(blkType,'SimscapeBlock');
end
