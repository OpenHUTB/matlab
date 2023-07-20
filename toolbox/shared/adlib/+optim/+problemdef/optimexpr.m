function expr=optimexpr(varargin)








    [outNames,outSize,NVpair]=optim.internal.problemdef.formatDimensionInput(varargin);



    if~isempty(NVpair)
        error(message('shared_adlib:validateIndexNames:InvalidDimensionInput'));
    end


    expr=optim.problemdef.OptimizationExpression(outSize,outNames);

end

