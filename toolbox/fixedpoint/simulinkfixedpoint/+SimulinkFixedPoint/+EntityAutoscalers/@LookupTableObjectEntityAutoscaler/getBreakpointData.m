function breakpointVector=getBreakpointData(lookupTableObject,dimension)



    breakpoint=lookupTableObject.Breakpoints(dimension);
    switch lookupTableObject.BreakpointsSpecification
    case 'Explicit values'
        breakpointVector=double(breakpoint.Value);
    case 'Even spacing'
        sizeOfTableData=size(lookupTableObject.Table.Value);
        if sizeOfTableData(1)==1



            N=sizeOfTableData(2);
        else
            N=sizeOfTableData(dimension);
        end
        firstPoint=double(breakpoint.FirstPoint);
        spacing=double(breakpoint.Spacing);
        breakpointVector=firstPoint+[0,spacing*(1:(N-1))];
    otherwise
        breakpointVector=[];
    end
end