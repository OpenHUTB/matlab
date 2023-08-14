function ext=getDebugFileExtension(hCS)







    tcName=get_param(hCS,'Toolchain');
    if isequal(tcName,coder.make.internal.getInfo('default-toolchain'))
        tcName=coder.make.getDefaultToolchain();
    end
    tc=coder.make.internal.getToolchainInfoFromRegistry(tcName);
    bt=tc.getBuildTool('Linker');
    ext=bt.getFileExtension('Executable');
    if isequal(tc.BuildArtifact,'nmake makefile')
        ext='.pdb';
    end
    return;
end
