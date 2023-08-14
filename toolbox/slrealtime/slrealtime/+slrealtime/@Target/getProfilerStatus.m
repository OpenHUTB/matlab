function ps=getProfilerStatus(tg)




    if tg.RunProfiler
        ps='StartRequested';
    elseif tg.tc.TracingConnected&&~isempty(tg.tc.TracingState)&&...
        tg.tc.TracingState~=slrealtime.internal.TracingState.STOPPED
        ps='Running';
    elseif~isempty(tg.getAvailableProfile('-all'))
        ps='DataAvailable';
    else
        ps='Ready';
    end
end
