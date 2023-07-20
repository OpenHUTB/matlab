function builtInOperationsFlag=useBuiltIn()











%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    builtInOperationsFlag=coder.const(coder.internal.coderNetworkUtils.isBlasEnabled()||...
    ~coder.const(@feval,'dlcoderfeature','UseCGIROptimizedLayerImplementation'));

end
