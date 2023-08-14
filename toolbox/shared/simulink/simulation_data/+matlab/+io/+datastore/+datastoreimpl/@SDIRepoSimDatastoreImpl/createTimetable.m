function[data,info]=createTimetable(~,vals,maxPts)



    ts=timeseries(vals.Data,vals.Time);
    if nargin>2&&maxPts
        len=length(ts.Time);
        if len>maxPts
            ts=delsample(ts,'Index',(maxPts+1:len));
        end
    end

    if isempty(ts.Time)
        data=timetable(seconds(ts.Time),ts.Data,'VariableNames',{'Data'});
    else
        data=Simulink.SimulationData.TimeseriesUtil.convertTimeSeriesToTimeTable(ts);
    end
    info=struct();
end
