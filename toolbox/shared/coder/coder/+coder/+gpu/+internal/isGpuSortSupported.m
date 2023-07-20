function result=isGpuSortSupported()





%#codegen
    coder.allowpcode('plain');
    coder.inline('always');
    result=coder.internal.targetLang('CUDA');
end
