



function args=getMakehdlArgs(hDI)






    dutName=hDI.hCodeGen.getDutName;
    hdlcoderObj=hdlcoderargs(dutName);
    isDUTModelReference=downstream.tool.isDUTModelReference(dutName);
    isDUTTopLevel=downstream.tool.isDUTTopLevel(dutName);


    if hDI.isIPCoreGen&&hDI.hIP.getIPCoreReportStatus
        generateReport='on';
    else
        generateReport='off';
    end


    if hdlwfsmartbuild.isSmartbuildOn(hDI.isMLHDLC,hDI.hCodeGen.ModelName)
        incrementalTopCli='on';
    else
        incrementalTopCli='off';
    end

    if~isDUTTopLevel
        snn=hdlcoderObj.OrigStartNodeName;
        hdlcoderObj.ModelName=hdlcoderObj.OrigModelName;
    else
        snn=hdlcoderObj.getStartNodeName;
    end


    mdlName=hdlcoderObj.ModelName;
    prefixOld=hdlget_param(mdlName,'ModulePrefix');
    if hDI.isIPCoreGen
        if~isDUTModelReference&&~isDUTTopLevel





            ipcoreName=hdlget_param(dutName,'IPCoreName');
            if isempty(ipcoreName)
                ipcoreName=hDI.hIP.getIPCoreName;
            end
        else
            ipcoreName=hDI.hIP.getIPCoreName;
        end
        prefixNew=sprintf('%s_src_%s',ipcoreName,prefixOld);
    else
        prefixNew=prefixOld;
    end


    if hDI.hTurnkey.hStream.isAXI4StreamFrameMode
        mapVectorPortToStream='on';
    else
        mapVectorPortToStream='off';
    end




    frameToSampleConversion='off';
    if hDI.hTurnkey.hStream.isFrameToSampleMode
        frameToSampleConversion='on';
        mapVectorPortToStream='off';
    end


    if strcmp(hdlfeature('AXI4StreamControlSignal'),'on')
        AXIStreamingTransformFeatureControl='on';
    else
        AXIStreamingTransformFeatureControl='off';
    end


    if strcmp(hdlfeature('SkipModelGeneration'),'on')
        generateModel='off';
    else
        generateModel='on';
    end


    args={'HDLSubsystem',snn,...
    'IPCoreReport',generateReport,...
    'IncrementalCodeGenForTopModel',incrementalTopCli,...
    'Backannotation','off',...
    'mapVectorPortToStream',mapVectorPortToStream,...
    'AXIStreamingTransformFeatureControl',AXIStreamingTransformFeatureControl,...
    'ModulePrefix',prefixNew,...
    'GenerateModel',generateModel,...
    'FrameToSampleConversion',frameToSampleConversion,...
    };
end


