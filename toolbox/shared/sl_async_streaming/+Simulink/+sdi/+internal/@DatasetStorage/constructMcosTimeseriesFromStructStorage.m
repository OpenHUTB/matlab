function obj=constructMcosTimeseriesFromStructStorage(strct,varargin)



    fullFlushIfNeeded(this);

    obj=Simulink.SimulationData.Storage.RamDatasetStorage.constructMcosTimeseriesFromStructStorage(...
    strct,varargin{:});
end
