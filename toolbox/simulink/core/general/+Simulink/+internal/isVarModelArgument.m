function TF=isVarModelArgument(modelName,varName)





    if~bdIsLoaded(modelName)
        load_system(modelName);
        oc=onCleanup(@()bdclose(modelName));
    end
    dictSystem=get_param(modelName,'DictionarySystem');
    dictParam=dictSystem.Parameter.getByKey(varName);

    TF=~isempty(dictParam)&&dictParam.Argument;
end