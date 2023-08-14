function hNIC=mlc2pir(fcnName,varargin)






    intsSaturate=true;

    [fcnInfoRegistry,exprMap,designNames]=internal.ml2pir.mlhdlc.FunctionInfoRegistryCache.getCacheValue(fcnName);


    internal.ml2pir.FunctionInfoRegistryCache.clearCacheValues;

    hNIC=internal.ml2pir.matlab2pir(fcnInfoRegistry,exprMap,designNames,fcnName,intsSaturate,@internal.ml2pir.mlhdlc.PIRGraphBuilder,varargin{:});
end


