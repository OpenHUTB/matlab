function pathItems=getPathItems(h,blkObj)%#ok





    pathItems={'Product 1',...
    'Accumulator 1',...
    'Product 2',...
    'Accumulator 2',...
    'Product 3',...
    'Product 4',...
    'Accumulator 4',...
    'Quotient'};


    if strcmp(blkObj.effMetricOut,'on')
        pathItems{end+1}='Accumulator 3';
        pathItems{end+1}='Eff Metric';
    end


