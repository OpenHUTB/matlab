function utilAdjustGenerateHDLCode(mdladvObj,hDI)





    hdlwa.utilAdjustGenerateHDLCodeTaskOnly(mdladvObj,hDI);



    hdlwa.WorkflowManager.updateWorkflow(mdladvObj);

    inputParams=mdladvObj.getInputParameters('com.mathworks.HDL.VerifyCosim');
    SkipVerifyCosim=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask'));

    inputParams=mdladvObj.getInputParameters('com.mathworks.HDL.RunMapping');
    SkipPreRouteTimingAnalysis=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipTimingAnalysis'));


    inputParams=mdladvObj.getInputParameters('com.mathworks.HDL.RunPandR');
    SkipPlaceAndRoute=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask'));
    IgnorePlaceAndRouteErrors=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputIgnorePandRError'));


    SkipVerifyCosim.Value=hDI.SkipVerifyCosim;
    SkipPreRouteTimingAnalysis.Value=hDI.SkipPreRouteTimingAnalysis;
    SkipPlaceAndRoute.Value=hDI.SkipPlaceAndRoute;
    IgnorePlaceAndRouteErrors.Value=hDI.IgnorePlaceAndRouteErrors;

    if(hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow)
        SkipPreRouteTimingAnalysis.Enable=false;
        SkipPlaceAndRoute.Enable=false;
        IgnorePlaceAndRouteErrors.Enable=false;
    else
        SkipPreRouteTimingAnalysis.Enable=true;
        SkipPlaceAndRoute.Enable=true;
        IgnorePlaceAndRouteErrors.Enable=true;
    end

end


