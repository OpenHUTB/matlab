function closeModel(modelName)




    if bdIsLoaded(modelName)
        close_system(modelName,0);
    end
end
