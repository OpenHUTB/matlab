function memoryUsage=getLUTDataMemoryUsage(breakpointSpecification,gridSize,breakpointWLs,tableValueWL,varargin)







    optargs={false,'linear'};
    optargs(1:numel(varargin))=varargin;
    [hdlOptimized,interpMethod]=optargs{:};

    if hdlOptimized
        memoryUsage=FunctionApproximation.internal.getLUTDataMemoryUsageForHDLOptimized(breakpointSpecification,...
        gridSize,breakpointWLs,tableValueWL,interpMethod);
    else
        if isEvenSpacing(breakpointSpecification)
            memoryUsage=[prod(gridSize),2*ones(1,numel(gridSize))]*[tableValueWL,breakpointWLs]';
        else
            memoryUsage=[prod(gridSize),gridSize]*[tableValueWL,breakpointWLs]';
        end
    end
end
