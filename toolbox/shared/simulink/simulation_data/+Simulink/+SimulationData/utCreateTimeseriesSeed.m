function tsWithUnits=utCreateTimeseriesSeed(name,units)



    tsWithUnits=timeseries.createSeed(name);
    if~isempty(units)
        tsWithUnits.DataInfo.units=Simulink.SimulationData.Unit(units);
    end
end
