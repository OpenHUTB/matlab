function[unitSystem,overrideUnits]=getUnitSystem()





    unitSystemInfo=Simulink.sdi.getUnitSystemAndOverrides();
    unitSystem=unitSystemInfo.UnitSystem;
    overrideUnits=[];
    if~isempty(unitSystemInfo.Overrides)
        overrideUnits=[""];%#ok
        for idx=1:length(unitSystemInfo.Overrides)
            overrideUnits(idx)=string(unitSystemInfo.Overrides{idx});
        end
    end
end