function pathItems=getPathItems(h,blkObj)%#ok





    pathItems={'Accumulator',...
    'Output'};

    if strcmp(blkObj.src_shear,'Specify via dialog')
        pathItems{end+1}='Shear values';
    end

    if~strcmp(blkObj.interpMethod,'Nearest neighbor')
        pathItems{end+1}='Product output';
    end


