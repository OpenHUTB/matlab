function toolchainName=getDefaultToolchainName()





    mexCompInfoDefault=coder.make.internal.getMexCompilerInfo();
    toolchainName=coder.make.internal.getToolchainNameFromRegistry...
    (mexCompInfoDefault.compStr);
end