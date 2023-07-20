function saveIfLoaded(modelName)



    if(bdIsLoaded(modelName))
        save_system(modelName);
    end
end