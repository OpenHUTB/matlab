function result=isGpuPersistentSupported()





%#codegen
    coder.allowpcode('plain');
    coder.inline('always');
    result=coder.internal.targetLang('CUDA');
end
