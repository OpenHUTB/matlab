function utilAdjustDetermineBASourceOptions(mdladvObj,hDI)




    if(strcmp(hDI.get('Tool'),'Xilinx Vivado'))
        taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.RunImplementation');
    else
        taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.RunPandR');
    end


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    SkipPlaceAndRoute=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask'));
    IgnorePlaceAndRouteErrors=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputIgnorePandRError'));


    SkipPlaceAndRoute.Value=hDI.SkipPlaceAndRoute;
    IgnorePlaceAndRouteErrors.Value=hDI.IgnorePlaceAndRouteErrors;


    if(hDI.SkipPlaceAndRoute)
        IgnorePlaceAndRouteErrors.Enable=false;
    else
        IgnorePlaceAndRouteErrors.Enable=true;
    end

    if(hDI.IgnorePlaceAndRouteErrors||hDI.SkipPreRouteTimingAnalysis)
        SkipPlaceAndRoute.Enable=false;
    else
        SkipPlaceAndRoute.Enable=true;
    end


    if(hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow)
        IgnorePlaceAndRouteErrors.Enable=false;
        SkipPlaceAndRoute.Enable=false;
    elseif(SkipPlaceAndRoute.Enable==false)
        IgnorePlaceAndRouteErrors.Enable=true;
    end

end


