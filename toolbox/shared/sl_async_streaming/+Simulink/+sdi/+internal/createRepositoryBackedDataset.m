function ds=createRepositoryBackedDataset(runID,domain,logIntervals,dlo)



    if nargin<2
        domain=[];
    end
    if nargin<3
        logIntervals=[];
    end
    if nargin<4
        dlo=[];
    end
    storage=Simulink.sdi.internal.DatasetStorage(runID,domain,logIntervals,dlo);
    ds=Simulink.SimulationData.Dataset(storage);
end

