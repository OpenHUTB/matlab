function obj=constructMcosTimetableFromStructStorage(strct,varargin)



    fullFlushIfNeeded(this);

    obj=Simulink.SimulationData.Storage.RamDatasetStorage.constructMcosTimetableFromStructStorage(...
    strct,varargin{:});
end
