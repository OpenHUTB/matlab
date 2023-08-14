function gridObject=updateGridForFlatInterpolation(gridObject)






    domains=gridObject.SingleDimensionDomains;
    for iDomain=1:numel(domains)
        if numel(domains{iDomain})>2
            domains{iDomain}(end)=[];
        end
    end
    gridObject=FunctionApproximation.internal.Grid(domains,gridObject.GridCreator);
end