function datasetWithDSTs=createSimulationDatastoresForDatasetRef(dsr)




    nEls=dsr.numElements;
    datasetWithDSTs=Simulink.SimulationData.Dataset;

    elementNames=getElementNames(dsr);

    if(isa(dsr.getStorage,...
        'Simulink.SimulationData.Storage.MatFileDatasetStorage'))
        for idx=1:nEls
            try
                element=dsr.getAsDatastore(idx);
            catch
                element=dsr.get(idx);
            end
            datasetWithDSTs=datasetWithDSTs.add(element,elementNames{idx});
        end
    else
        for idx=1:nEls
            element=dsr.get(idx);
            datasetWithDSTs=datasetWithDSTs.add(element,elementNames{idx});
        end
    end
end
