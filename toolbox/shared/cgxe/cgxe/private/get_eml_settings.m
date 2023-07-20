function ret=get_eml_settings(blkHandle)



    modelH=bdroot(blkHandle);
    cs=getActiveConfigSet(modelH);
    ret.enableRuntimeRecursion=strcmp(get_param(cs,'EnableRuntimeRecursion'),'on');
    ret.compileTimeRecursionLimit=get_param(cs,'CompileTimeRecursionLimit');
    ret.enableImplicitExpansion=strcmp(get_param(cs,'EnableImplicitExpansion'),'on');
    ret.MATLABDynamicMemAlloc=strcmp(get_param(cs,'MATLABDynamicMemAlloc'),'on');
    ret.MATLABDynamicMemAllocThreshold=get_param(cs,'MATLABDynamicMemAllocThreshold');
