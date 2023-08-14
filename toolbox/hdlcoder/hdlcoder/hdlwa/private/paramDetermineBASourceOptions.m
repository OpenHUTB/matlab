function paramDetermineBASourceOptions(taskobj)




    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    SkipPlaceAndRoute=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask'));
    IgnorePlaceAndRouteErrors=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputIgnorePandRError'));

    if(SkipPlaceAndRoute.Value~=hDI.SkipPlaceAndRoute)
        hDI.SkipPlaceAndRoute=SkipPlaceAndRoute.Value;
    elseif(IgnorePlaceAndRouteErrors.Value~=hDI.IgnorePlaceAndRouteErrors)
        hDI.IgnorePlaceAndRouteErrors=IgnorePlaceAndRouteErrors.Value;
    end

    if(hDI.SkipPlaceAndRoute)
        hDI.IgnorePlaceAndRouteErrors=false;
    end




    taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.AnnotateModel');


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    critPath=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputCriticalPathSource'));

    if hDI.SkipPlaceAndRoute&&~hDI.SkipPreRouteTimingAnalysis
        critPath.Entries={'pre-route'};
        hDI.CriticalPathSource='pre-route';
    elseif~hDI.SkipPlaceAndRoute&&hDI.SkipPreRouteTimingAnalysis
        critPath.Entries={'post-route'};
        hDI.CriticalPathSource='post-route';
    elseif~hDI.SkipPlaceAndRoute&&~hDI.SkipPreRouteTimingAnalysis
        critPath.Entries={'pre-route','post-route'};
        hDI.CriticalPathSource='pre-route';
    else

    end


    utilAdjustDetermineBASourceOptions(mdladvObj,hDI);
    utilAdjustAnnotateModel(mdladvObj,hDI);


end


