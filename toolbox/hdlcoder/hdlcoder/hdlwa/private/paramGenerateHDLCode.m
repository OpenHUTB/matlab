function paramGenerateHDLCode(taskobj)



    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    GenerateRTLCode=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateRTLCode'));
    GenerateTestbench=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateTestbench'));
    GenerateValidationModel=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateCovalidationModel'));



    if(GenerateRTLCode.Value~=hDI.GenerateRTLCode)
        hDI.GenerateRTLCode=GenerateRTLCode.Value;
    elseif(GenerateTestbench.Value~=hDI.GenerateTestbench)
        hDI.GenerateTestbench=GenerateTestbench.Value;
    elseif(GenerateValidationModel.Value~=hDI.GenerateValidationModel)
        hDI.GenerateValidationModel=GenerateValidationModel.Value;
    end


    if(hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow||hDI.isFILWorkflow)
        hDI.GenerateRTLCode=true;
    end


    if(hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow)
        hDI.SkipPreRouteTimingAnalysis=true;
        hDI.SkipPlaceAndRoute=false;
        hDI.IgnorePlaceAndRouteErrors=false;
    else
        hDI.SkipPreRouteTimingAnalysis=false;
    end



    utilAdjustGenerateHDLCode(mdladvObj,hDI);



