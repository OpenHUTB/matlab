function[percent,percentStr]=utilGetSimTimePercentage(mdl)

    currentTime=get_param(mdl,'SimulationTime');
    startTimeStr=get_param(mdl,'StartTime');
    stopTimeStr=get_param(mdl,'StopTime');

    startTime=str2double(startTimeStr);
    stopTime=str2double(stopTimeStr);
    if isnan(stopTime)
        try
            stopTime=evalin('base',stopTimeStr);
        catch
        end
    end

    percent=(currentTime-startTime)*100/(stopTime-startTime);
    if percent<0,percent=0;end
    if percent>100,percent=100;end
    if percent<1
        percentStr=sprintf('%0.2f',percent);
    else
        percentStr=sprintf('%d',round(percent));
    end

end