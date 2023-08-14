function pathItems=getPathItems(~,blkObj)



    pathItems={'Table'};
    switch blkObj.Object.BreakpointsSpecification


    case{'Explicit values','Even spacing'}
        for iBP=1:numel(blkObj.Object.Breakpoints)
            pathItems=[pathItems,{['Breakpoint',num2str(iBP,'%g')]}];%#ok<AGROW>
        end
    end
end


