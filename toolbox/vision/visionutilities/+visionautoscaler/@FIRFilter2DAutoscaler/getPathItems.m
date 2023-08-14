function pathItems=getPathItems(h,blkObj)%#ok






    pathItems={'Product output',...
    'Accumulator',...
    'Output'};
    if strcmp(blkObj.filtSrc,'Specify via dialog')
        pathItems{end+1}='Coefficients';
    end


