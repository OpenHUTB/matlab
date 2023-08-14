function exeFile=getExecutableFile(modelName,codeGenFolder)





    toolchainName=get_param(modelName,'Toolchain');
    if isequal(toolchainName,coder.make.internal.getInfo('default-toolchain'))
        toolchainName=codertarget.utils.getDefaultToolchainName();
    end
    toolchain=coder.make.internal.getToolchainInfoFromRegistry(toolchainName);

    linker=toolchain.getBuildTool('Linker');
    b=linker.FileExtensions;
    c=b.getValue('Executable');
    ext=c.getValue();



    exeFile=fullfile(codeGenFolder,[modelName,ext]);
end