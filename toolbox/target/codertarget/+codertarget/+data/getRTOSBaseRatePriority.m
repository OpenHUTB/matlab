function rate=getRTOSBaseRatePriority(hObj)




    if ischar(hObj)
        cs=getActiveConfigSet(hObj);
    else
        cs=hObj.getConfigSet();
    end
    rate='';
    if cs.isValidParam('CoderTargetData')
        data=get_param(cs,'CoderTargetData');
        if isfield(data,'RTOS')&&~isequal(data.RTOS,'Baremetal')
            if isfield(data,'RTOSBaseRateTaskPriority')
                rate=data.RTOSBaseRateTaskPriority;
            end
            if~isequal(((str2double(rate))-double(int32(str2double(rate)))),0.0)
                rate='non-integer';
            end
        end
    end
end