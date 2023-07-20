function aTimeSeries=createTimeSeries(data,time)









    try
        aTimeSeries=timeseries(data,time);
    catch err %#ok<NASGU>


        aTimeSeries=timeseries(data,double(time));
    end

end