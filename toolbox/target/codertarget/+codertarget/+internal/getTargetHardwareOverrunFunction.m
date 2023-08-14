function call=getTargetHardwareOverrunFunction(hObj)





    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

    data=codertarget.data.getData(hObj);
    call={};
    needOverrunFunctionality=(isfield(data,'OverRunDetection')&&...
    isfield(data.OverRunDetection,'Enable_overrun_detection')&&...
    (isfield(data.OverRunDetection,'Check_GPIO_Status')||...
    isfield(data.OverRunDetection,'Custom_Logic')));

    if(needOverrunFunctionality)
        if isequal(data.OverRunDetection.Enable_overrun_detection,1)
            call{1}='executeOverrunService()';
            if isfield(data.OverRunDetection,'Check_GPIO_Status')&&...
                isequal(data.OverRunDetection.Check_GPIO_Status,1)
                call{2}='initializeOverrunService()';
            else
                call{2}='';
            end
        else
            call{1}='';
            call{2}='';
        end
    else
        call{1}='';
        call{2}='';
    end
end


