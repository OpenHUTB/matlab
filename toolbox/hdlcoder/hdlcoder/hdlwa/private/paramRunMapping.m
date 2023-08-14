function paramRunMapping(taskobj)




    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    if(hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow)
        return;
    end


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    SkipPreRouteTimingAnalysis=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipTimingAnalysis'));


    if(SkipPreRouteTimingAnalysis.Value~=hDI.SkipPreRouteTimingAnalysis)
        hDI.SkipPreRouteTimingAnalysis=SkipPreRouteTimingAnalysis.Value;
    end



    if hDI.SkipPreRouteTimingAnalysis
        hDI.SkipPlaceAndRoute=false;
    else
        hDI.SkipPlaceAndRoute=true;
        hDI.IgnorePlaceAndRouteErrors=false;
    end



    utilAdjustMapping(mdladvObj,hDI);
    utilAdjustDetermineBASourceOptions(mdladvObj,hDI);

end

