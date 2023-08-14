function areOpen=areModelsOpen(modelNames)



    if(~iscell(modelNames))
        modelNames={modelNames};
    end

    if rtwprivate('hasSimulink')
        openModels=find_system('type','block_diagram');
    else
        openModels={};
    end
    areOpen=ismember(modelNames,openModels);
end