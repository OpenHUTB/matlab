function saveFiltersToJSON(modelName,filePath)



    manager=slcheck.getAdvisorFilterManager(modelName);

    serializer=mf.zero.io.JSONSerializer;
    serializer.serializeToFile(mf.zero.getModel(manager),filePath);

end