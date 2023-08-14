

function forceCloseModel(modelPath)

    [~,modelName,~]=fileparts(modelPath);

    if(isvarname(modelName)&&...
        bdIsLoaded(modelName)...
        &&strcmp(get_param(modelName,'FileName'),modelPath))
        close_system(modelName,0);
    end

end
