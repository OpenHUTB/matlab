function SampleDims=getTSDimension(ts)





    if isa(ts,'timeseries')||isa(ts,'Simulink.Timeseries')

        SampleDims=SlIOFormatUtil.getTimeseriesDimension(ts);
    else
        DAStudio.error('sl_sta_repository:item:InvalidTimeSeries');
    end

end

