function numberOfPoints=getNumberOfPointsExplicitValuesMode(~,blockObject)







    switch blockObject.BreakpointsDataSource

    case 'Dialog'
        numberOfPoints=numel(double(slResolve(blockObject.BreakpointsData,blockObject.Handle)));
    case 'Input port'
        portHandles=blockObject.PortHandles;
        breakpointSourcePort=get_param(portHandles.Inport(blockObject.Ports(1)),'Object');
        numberOfPoints=prod(breakpointSourcePort.CompiledPortDimensions);
    end
end