


function dtList=getDataTypesVisibleToModel(modelName)



    if~bdIsLoaded(modelName)
        load_system(modelName);
    end
    [dtList,~]=slprivate('slGetUserDataTypesFromWSDD',get_param(modelName,'Object'),[],[],true);
end


