function clock=getSystemClock(hObj)




    if ischar(hObj)
        cs=getActiveConfigSet(hObj);
    else
        cs=hObj.getConfigSet();
    end
    clock='0';
    if cs.isValidParam('CoderTargetData')
        data=get_param(cs,'CoderTargetData');
        if isfield(data,'Clocking')
            if isfield(data.('Clocking'),'ClosestCpuClock')
                clock=data.Clocking.ClosestCpuClock;
            elseif isfield(data.('Clocking'),'cpuClockRateMHz')
                clock=data.Clocking.cpuClockRateMHz;
            end
        end
    end
end