function files=getFileDependencies(~,selectedModel)





    files=cell.empty;

    if~isequal(selectedModel,0)
        files=getModelDependencies(selectedModel);
    end
end

function files=getModelDependencies(selectedModel)

    [~,modelName]=fileparts(selectedModel);

    if~bdIsLoaded(modelName)
        load_system(selectedModel);
    end

    files=...
    dependencies.fileDependencyAnalysis(modelName,[],true);
    files=evolutions.internal.utils.makeCell(files);
end

