

function scopeTimeSpan=getScopeAutoTimeSpan(modelName,isTimeSpanAuto,timeSpan)
    mdlStopTime=get_param(modelName,'StopTime');
    mdlStartTime=get_param(modelName,'StartTime');
    if isTimeSpanAuto
        if isvarname(mdlStopTime)||...
            isvarname(mdlStartTime)||...
            isinf(str2double(mdlStopTime))



            scopeTimeSpan=10;
        else
            scopeTimeSpan=eval(mdlStopTime)-eval(mdlStartTime);
        end
    else

        scopeTimeSpan=timeSpan;
    end
end
