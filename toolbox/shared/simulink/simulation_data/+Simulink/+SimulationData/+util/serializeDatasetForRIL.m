function[serializedDataset,diagStruct]=serializeDatasetForRIL(...
    extInputs,interpolation,inportHandles,bdhandle,isSynthetic,...
    isForConsistencyCheck)



    if nargin<6


        isForConsistencyCheck=false;
    end



    model=get_param(bdhandle,'Name');










    partialBuildData.mdl=model;
    partialBuildData.timeSpan=[];

    [aobHierarchy,leafSignalOffset,portBusTypes,msgPortIdxs]=...
    Simulink.SimulationData.util.retrieveAoBHierarchy(model,inportHandles,[]);

    if nargin>4
        if isSynthetic
            serializer=Simulink.SimulationData.SerializeInput.RtInpNonDatasetSerializer(...
            partialBuildData,...
            model,...
            extInputs,...
            aobHierarchy,...
            interpolation,...
            portBusTypes,...
            msgPortIdxs,...
            isForConsistencyCheck,...
            []...
            );
        else
            serializer=Simulink.SimulationData.SerializeInput.RtInpDatasetSerializer(...
            partialBuildData,...
            model,...
            extInputs,...
            aobHierarchy,...
            interpolation,...
            portBusTypes,...
            msgPortIdxs,...
            isForConsistencyCheck,...
            []...
            );
        end

        try
            [serializedDataset,diagStruct]=serializer.serializeDataset();
        catch ME
            throwAsCaller(ME);
        end
    else
        diagStruct=[];
        serializedDataset=Simulink.SimulationData.util.serializeDatasetToNoMCOS(...
        partialBuildData,...
        model,...
        extInputs,...
        aobHierarchy,...
        interpolation,...
portBusTypes...
        );
    end
    if~isForConsistencyCheck
        serializedDataset=...
        Simulink.SimulationData.util.addLeafOffsetsToSerializedDataset(...
        serializedDataset,...
        aobHierarchy,...
leafSignalOffset...
        );
    end
end


