function pathItems=getPathItems(h,blkObj)%#ok





    if strcmp(blkObj.methodInputRange,...
        'Range determined by saturating outlier pixels')
        pathItems={'Product 1','Product 2'};
    else
        pathItems={'Product 1'};
    end


