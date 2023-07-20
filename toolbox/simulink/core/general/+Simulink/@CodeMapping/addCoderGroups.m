function addCoderGroups(modelName,creationMode)




    modelName=get_param(modelName,'Name');
    hlp=coder.internal.CoderDataStaticAPI.getHelper;

    slRoot=slroot;
    if slRoot.isValidSlObject(modelName)
        localDD=hlp.openDD(get_param(modelName,'Handle'),'C',true);
    end
    if~coder.internal.CoderDataStaticAPI.migratedToCoderDictionary(modelName)


        coder.internal.CoderDataStaticAPI.initializeDictionary(modelName);
        if strcmp(creationMode,'testing')
            coder.internal.CoderDataStaticAPI.createInternal(localDD,creationMode);
        end
    end
end
