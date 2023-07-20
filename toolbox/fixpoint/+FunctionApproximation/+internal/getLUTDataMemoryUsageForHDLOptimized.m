function memoryUsage=getLUTDataMemoryUsageForHDLOptimized(breakpointSpecification,gridSize,breakpointWLs,tableValueWL,interpolation)





    memoryUsage=NaN;
    if isEvenSpacing(breakpointSpecification)
        if strcmp(interpolation,'linear')
            memoryUsage=2*gridSize*tableValueWL+2*breakpointWLs+18;
        else
            memoryUsage=gridSize*tableValueWL+2*breakpointWLs+18;
        end
    end
end