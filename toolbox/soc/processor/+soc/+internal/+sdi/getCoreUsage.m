function[usedDurations,idleDurations]=getCoreUsage(core)






    usedDurations=locGetDurations(core,true);
    idleDurations=locGetDurations(core,false);
end


function durations=locGetDurations(core,option)
    if option
        idxTargetStates=find(core.Data~='Idle');
    else
        idxTargetStates=find(core.Data=='Idle');
    end
    durations=[];
    if~isempty(idxTargetStates)
        endIdx=idxTargetStates(1)-1;
        for ii=1:length(idxTargetStates)
            thisDuration=0;
            startIdx=endIdx+1;
            if(startIdx>=length(core.Data))
                break;
            end

            endIdx=startIdx;
            while(mycompare(core.Data{endIdx})&&(endIdx<length(core.Data)))
                endIdx=endIdx+1;
                thisDuration=thisDuration+core.Time(endIdx)-core.Time(endIdx-1);
            end
            if~isequal(thisDuration,0)
                durations=[durations;thisDuration];%#ok<*AGROW>
            end
        end
        durations=durations';
    end
    function res=mycompare(state)
        if option
            res=~isequal(state,'Idle');
        else
            res=isequal(state,'Idle');
        end
    end
end