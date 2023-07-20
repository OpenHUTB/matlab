function this=utfillfromstruct(this,datasetStruct)



    if~isempty(datasetStruct)
        assert(this.numElements==0);
        this=utSetElements(...
        this,...
        locConstructMcosElementArrayFromStructStorage(this,...
        datasetStruct.Elements...
        )...
        );
    else
        this=[];
    end
end



function objArray=...
    locConstructMcosElementArrayFromStructStorage(this,structArray)



    nElements=length(structArray);
    objArray=cell(1,nElements);
    for idx=1:nElements
        if isa(structArray{idx},'Stateflow.SimulationData.Data')...
            ||isa(structArray{idx},'Stateflow.SimulationData.State')...
            ||isa(structArray{idx},'Simulink.SimulationData.Signal')
            objArray{idx}=structArray{idx};
        else
            objArray{idx}=...
            Simulink.SimulationData.Storage.DatasetStorage....
            constructMcosElementFromStructStorage(...
            this,...
            structArray{idx}...
            );
        end
    end
end



