function isReset=utilParseDetermineBASourceOptions(mdladvObj,hDI)



    if(strcmp(hDI.get('Tool'),'Xilinx Vivado'))
        taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.RunImplementation');
    else
        taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.RunPandR');
    end


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    SkipPlaceAndRoute=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask'));
    IgnorePlaceAndRouteErrors=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputIgnorePandRError'));
    isReset=false;

    try
        if~isequal(SkipPlaceAndRoute.Value,hDI.SkipPlaceAndRoute)
            hDI.SkipPlaceAndRoute=SkipPlaceAndRoute.Value;
        end
        if~isequal(IgnorePlaceAndRouteErrors.Value,hDI.IgnorePlaceAndRouteErrors)
            hDI.IgnorePlaceAndRouteErrors=IgnorePlaceAndRouteErrors.Value;
        end
    catch ME

        taskObj.reset;
        isReset=true;

        errorMsg=sprintf(['Error occurred in Task 4.2 when loading Restore Point.\n',...
        'The error message is:\n%s\n'],...
        ME.message);
        hf=errordlg(errorMsg,'Error','modal');

        set(hf,'tag','load Post Route Timing error dialog');
        setappdata(hf,'MException',ME);
    end

end


