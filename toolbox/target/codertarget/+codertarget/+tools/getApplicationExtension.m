function[ext,toolchain]=getApplicationExtension(mdlName)



    toolchainName=get_param(mdlName,'Toolchain');
    if isequal(toolchainName,coder.make.internal.getInfo('default-toolchain'))
        toolchainName=coder.make.getDefaultToolchain();
    end
    toolchain=coder.make.internal.getToolchainInfoFromRegistry(toolchainName);
    linker=toolchain.getBuildTool('Linker');
    b=linker.FileExtensions;
    c=b.getValue('Executable');
    ext=c.getValue;

