function pathItems=getPathItems(h,blkObj)





    if(hideFixptTabParameters(h,blkObj))
        pathItems={};
    else
        if(hideAccProdFixptTabParameters(h,blkObj))
            pathItems={'Output'};
        else
            pathItems={'Product output',...
            'Accumulator',...
            'Output'};
        end

        if~ResizeWithoutTable(h,blkObj)
            pathItems{end+1}='Interpolation weights table';
        end
    end


