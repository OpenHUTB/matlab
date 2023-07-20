function numberOfPoints=getNumberOfPoints(h,blockObject)






    switch blockObject.BreakpointsSpecification

    case 'Even spacing'

        numberOfPoints=double(slResolve(blockObject.BreakpointsNumPoints,blockObject.Handle));
    case 'Explicit values'

        numberOfPoints=getNumberOfPointsExplicitValuesMode(h,blockObject);
    case 'Breakpoint object'

        breakpointObject=slResolve(blockObject.BreakpointObject,blockObject.Handle,'variable','startUnderMask');
        numberOfPoints=numel(breakpointObject.Breakpoints.Value);
    end
end
