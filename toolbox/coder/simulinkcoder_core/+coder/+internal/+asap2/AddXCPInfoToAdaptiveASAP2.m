function AddXCPInfoToAdaptiveASAP2(modelName,qualifedFileName,mapFile,customizationObject)








    isCompliant=Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName);
    if~isCompliant
        DAStudio.error('autosarstandard:api:a2lExportCompliant');
    end

    xcpMode=get_param(modelName,'AdaptiveAutosarXCPSlaveTransportLayer');

    if strcmp(xcpMode,'None')
        return;
    end



    buildDir=RTW.getBuildDir(modelName).BuildDirectory;


    a2lFile=fullfile(qualifedFileName);
    a2lFileContent=fileread(a2lFile);
    if~isempty(mapFile)


        a2lFileContent=strrep(a2lFileContent,'::','.');
    end

    port=int32(str2double(get_param(modelName,'AdaptiveAutosarXCPSlavePort')));
    if((port>0)&&(port<=65535))
        port=double(port);
    else
        MSLDiagnostic('coder_xcp:host:InvalidTCPIPPortNumber',port).reportAsWarning;
    end

    switch(xcpMode)
    case 'XCPOnTCPIP'
        transportLayerInfo=coder.internal.xcp.a2l.TcpTransportLayerInfo(...
        get_param(modelName,'AdaptiveAutosarXCPSlaveTCPIPAddress'),port);
    otherwise
    end

    buildInfo=load(fullfile(buildDir,'buildInfo.mat')).buildInfo;
    defineMap=coder.internal.xcp.a2l.DefineMapFactory.fromBuildInfo(buildInfo);

    cDesc=coder.getCodeDescriptor(buildDir);
    compInterface=cDesc.getComponentInterface;
    periodicEventList=coder.internal.xcp.a2l.PeriodicEventList(compInterface);

    cfgSet=getActiveConfigSet(modelName);
    isCompiledWithPWS=defineMap.isKey('PORTABLE_WORDSIZES');
    typeInfo=coder.internal.xcp.getTypeInfo(cfgSet,isCompiledWithPWS);

    ifDataXcp=asam.mcd2mc.create('IFDataXCPInfo');
    ifDataXcpBuilder=coder.internal.xcp.a2l.slcoderslave.IFDataXCPBuilder();
    ifDataXcpBuilder.build(defineMap,periodicEventList,transportLayerInfo,typeInfo,ifDataXcp);


    coder.internal.xcp.a2l.writeA2LFileWithIFDataXCP(qualifedFileName,a2lFileContent,ifDataXcp,'CustomizationObject',customizationObject);
end


