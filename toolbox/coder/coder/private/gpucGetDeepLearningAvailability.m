function[hasMatlabCoder,hasGpuCoder]=gpucGetDeepLearningAvailability()





    hasMatlabCoder=coder.internal.gui.safeFeval('dlcoder_base.internal.isMATLABCoderDLTargetsInstalled',false);
    hasGpuCoder=coder.internal.gui.safeFeval('dlcoder_base.internal.isGpuCoderDLTargetsInstalled',false);
end