function usedDurations=getCoreUsageByTask(core,task)







    usedDurations=locGetDurations(core,task);
end


function durations=locGetDurations(core,task)
    idxTargetStates=find(core.Data==task);
    durations=[];
    if~isempty(idxTargetStates)
        for ii=1:length(idxTargetStates)
            if isequal(idxTargetStates(ii),length(core.Time)),break;end
            thisDuration=core.Time(idxTargetStates(ii)+1)-...
            core.Time(idxTargetStates(ii));
            durations=[durations,thisDuration];
        end
    end
    durations=durations';
end