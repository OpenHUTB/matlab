function[isValid,minimumValue,maximumValue,parameterObject]=getBreakpointData(h,blockObject)






    isValid=false;
    minimumValue=[];
    maximumValue=[];
    parameterObject=[];
    pathItems=getPathItems(h,blockObject);
    if ismember('Breakpoint',pathItems)
        switch blockObject.BreakpointsSpecification

        case 'Explicit values'

            [isValid,minimumValue,maximumValue,parameterObject]=SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blockObject,blockObject.BreakpointsData);
        case 'Even spacing'

            isValid=true;
            minimumValue=double(slResolve(blockObject.BreakpointsFirstPoint,blockObject.Handle));
            spacing=double(slResolve(blockObject.BreakpointsSpacing,blockObject.Handle));
            numPoints=getNumberOfPoints(h,blockObject);
            maximumValue=minimumValue+spacing*(numPoints-1);
        end
    end
end