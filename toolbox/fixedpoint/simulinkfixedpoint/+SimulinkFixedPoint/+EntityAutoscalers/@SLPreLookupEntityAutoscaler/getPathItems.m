function pathItems=getPathItems(h,blkObj)%#ok






    if strcmp(blkObj.OutputSelection,'Index and fraction')
        pathItems={'1','2'};
    else
        pathItems={'1'};
    end

    if ismember(blkObj.BreakpointsSpecification,{'Explicit values','Even spacing'})...
        &&strcmp(blkObj.BreakpointsDataSource,'Dialog')
        pathItems{end+1}='Breakpoint';
    end
end