function pathItems=getPathItems(h,blkObj)%#ok





    pathItems={};

    isFixptOutput=strncmpi(blkObj.outdtmode,'Specify',2);
    if isFixptOutput
        pathItems{end+1}='Accumulator';
        pathItems{end+1}='Product output';
    end


