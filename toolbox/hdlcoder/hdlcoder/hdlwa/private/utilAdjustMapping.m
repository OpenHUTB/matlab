function utilAdjustMapping(mdladvObj,hDI)





    if(strcmpi(hDI.get('Tool'),'Xilinx Vivado')||strcmpi(hDI.get('Tool'),'Microchip Libero SoC'))
        taskObj1=mdladvObj.getTaskObj('com.mathworks.HDL.RunVivadoSynthesis');
        taskObj2=mdladvObj.getTaskObj('com.mathworks.HDL.RunImplementation');
    else
        taskObj1=mdladvObj.getTaskObj('com.mathworks.HDL.RunMapping');
        taskObj2=mdladvObj.getTaskObj('com.mathworks.HDL.RunPandR');
    end


    inputParams=mdladvObj.getInputParameters(taskObj1.MAC);
    SkipPreRouteTimingAnalysis=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipTimingAnalysis'));

    inputParams=mdladvObj.getInputParameters(taskObj2.MAC);
    SkipPlaceAndRoute=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask'));


    enSkipPreRouteTimingAnalysis=SkipPreRouteTimingAnalysis.Enable;
    if strcmpi(hDI.get('Tool'),'Microchip Libero SoC')


        hDI.SkipPreRouteTimingAnalysis=true;
        hDI.SkipPlaceAndRoute=false;
        SkipPreRouteTimingAnalysis.Enable=false;
    else
        SkipPreRouteTimingAnalysis.Enable=enSkipPreRouteTimingAnalysis;
    end
    SkipPreRouteTimingAnalysis.Value=hDI.SkipPreRouteTimingAnalysis;
    SkipPlaceAndRoute.Value=hDI.SkipPlaceAndRoute;


    if SkipPreRouteTimingAnalysis.Value
        SkipPlaceAndRoute.Enable=false;
    else
        SkipPlaceAndRoute.Enable=true;
    end

end