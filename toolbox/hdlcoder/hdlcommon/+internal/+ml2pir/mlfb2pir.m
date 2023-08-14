function hNIC=mlfb2pir(blockName,varargin)





    [fcnInfoRegistry,exprMap,designNames]=internal.ml2pir.mlfb.FunctionInfoRegistryCache.getCacheValue(blockName);

    intsSaturate=internal.ml2pir.mlfb.getIntegersSaturateOnOverflow(blockName);
    mlfbN=get_param(blockName,'Name');

    hNIC=internal.ml2pir.matlab2pir(fcnInfoRegistry,exprMap,designNames,mlfbN,intsSaturate,@internal.ml2pir.mlfb.PIRGraphBuilder,varargin{:});
end
