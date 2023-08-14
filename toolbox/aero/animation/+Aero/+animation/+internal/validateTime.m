function validateTime(time,timeTimeseries)






    minTime=min(timeTimeseries(isfinite(timeTimeseries)));
    maxTime=max(timeTimeseries(isfinite(timeTimeseries)));

    if isduration(minTime)
        minTime=seconds(minTime);
        maxTime=seconds(maxTime);
    end


    if any(time<minTime)
        error(message('aero:validateTime:startTimeBeforeData'));
    end


    if any(time>maxTime)
        error(message('aero:validateTime:finalTimeAfterData'));
    end

end