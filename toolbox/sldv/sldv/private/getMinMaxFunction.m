function status=getMinMaxFunction(blockH)




    blkFunction=get_param(blockH,'Function');
    if strcmp(blkFunction,'min')
        status=true;
    else
        status=false;
    end
end

