function result=isGpuReduceSupported()

%#codegen
    coder.allowpcode('plain');
    coder.inline('always');
    result=coder.internal.targetLang('CUDA');
end
