function ts=convertToMATLABTimeseries(simTs)





    if simTs.isframe
        DAStudio.error('Simulink:SimInput:ConvertTimeseriesFrames');
    end














    if~isnan(simTs.TimeInfo.Increment)&&length(simTs.TimeInfo.Start)==1
        ts=timeseries.utcreateuniformwithoutcheck(simTs.Data,...
        simTs.TimeInfo.Length,...
        simTs.TimeInfo.Start,...
        simTs.TimeInfo.Increment,...
        false,...
        false);
    else
        ts=timeseries.utcreatewithoutcheck(simTs.Data,...
        simTs.Time,...
        false,...
        false);
    end


    ts.Name=simTs.Name;



    ts.DataInfo=simTs.DataInfo;



    ts.TimeInfo.Units=simTs.TimeInfo.Units;
    if~isempty(simTs.TimeInfo.UserData)
        ts.TimeInfo.UserData=simTs.TimeInfo.UserData;
    end
end

