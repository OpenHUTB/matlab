function pathItems=getPathItems(h,blkObj)%#ok





    pathItems={};

    if strcmp(blkObj.centroid,'on')||strcmp(blkObj.extent,'on')
        pathItems{end+1}='Accumulator';
    end

    if strcmp(blkObj.centroid,'on')

        pathItems{end+1}='Centroid output';
    end

    if strcmp(blkObj.equivDiameterSq,'on')
        pathItems{end+1}='Product output';
        pathItems{end+1}='Equiv Diam^2 output';
    end

    if strcmp(blkObj.extent,'on')

        pathItems{end+1}='Extent output';
    end

    if strcmp(blkObj.perimeter,'on')
        pathItems{end+1}='Perimeter output';
    end


