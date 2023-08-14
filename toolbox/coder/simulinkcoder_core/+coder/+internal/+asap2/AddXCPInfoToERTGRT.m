function AddXCPInfoToERTGRT(modelName,qualifedFileName,customizationObject)










    buildDir=RTW.getBuildDir(modelName);
    buildInfo=coder.make.internal.loadBuildInfo(buildDir.BuildDirectory);
    cDesc=coder.getCodeDescriptor(buildDir.BuildDirectory);
    compInterface=cDesc.getComponentInterface;
    cfgSet=getActiveConfigSet(modelName);
    ifDataXcp=coder.internal.xcp.a2l.slcoderslave.createIFDataXCPInfo(...
    modelName,...
    buildInfo,...
    buildDir.BuildDirectory,...
    cfgSet,...
    compInterface);
    a2lFileContent=fileread(qualifedFileName);

    coder.internal.xcp.a2l.writeA2LFileWithIFDataXCP(qualifedFileName,a2lFileContent,ifDataXcp,'CustomizationObject',customizationObject);
end


