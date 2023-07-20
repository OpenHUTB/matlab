function toolchainInfo=getToolchainForSILPWSBuild(lBuildTools)




    toolchainInfo=coder.make.internal.getToolchainInfoFromRegistry(...
    lBuildTools.Toolchain,'');
end


