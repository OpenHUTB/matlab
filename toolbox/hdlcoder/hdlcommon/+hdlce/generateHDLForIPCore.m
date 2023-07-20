function generateHDLForIPCore(refMdlName,targetMappingInfo,params)





    hdlset_param(refMdlName,'HDLSubsystem',refMdlName);
    hdlset_param(refMdlName,'TargetDir',fullfile('hdl_prj','hdlsrc'));

    hDI=downstream.integration('Model',refMdlName,'cmdDisplay',true);

    hDI.set('Workflow',params.workflow);
    hDI.isMDS=true;

    architectureName=params.defaultArchitectureName;
    if(any(strcmp(targetMappingInfo.ArchitectureName,params.supportBoards)))
        architectureName=targetMappingInfo.ArchitectureName;
    end

    hDI.set('Board',architectureName);


    assert(strcmp(targetMappingInfo.ExecutionMode,'Free running')||...
    strcmp(targetMappingInfo.ExecutionMode,'Coprocessing - blocking'));
    hDI.set('ExecutionMode',targetMappingInfo.ExecutionMode);






    hDI.hIP.setIPCoreName(lower([refMdlName,'_pcore']));


    hDI.initTargetInterface;


    for k=1:length(targetMappingInfo.PortNames)
        hDI.setTargetInterface(targetMappingInfo.PortNames{k},params.supportedInterface);
        portAddr=dec2hex(str2double(targetMappingInfo.PortAddresses{k}));
        portAddr=['x"',portAddr,'"'];%#ok
        hDI.setTargetOffset(targetMappingInfo.PortNames{k},portAddr);
    end

    hDI.validateTargetInterface;

    hDI.dispTargetInterface;


    hDI.runIPCoreCodeGen;


    if(any(strcmp(targetMappingInfo.ArchitectureName,params.supportBoards)))

        hDI.runCreateEmbeddedProject();





        hDI.hIP.GenerateSoftwareInterfaceModel=false;
        hDI.hIP.GenerateHostInterfaceModel=false;
        hDI.hIP.GenerateHostInterfaceScript=false;
        hDI.runSWInterfaceGen;


        hDI.hIP.setEmbeddedExternalBuild(0);
        hDI.runEmbeddedSystemBuild();


        try

            hDI.hIP.setProgrammingMethod(hdlcoder.ProgrammingMethod.Download);
            hDI.runEmbeddedDownloadBitstream();
        catch ME
            warning(ME.identifier,ME.message);
        end
    end
end




