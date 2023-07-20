function createDict(dictFileName,packageName)







    dictPath=[dictFileName,'.sldd'];
    if exist(dictPath,'file')
        ddConnection=Simulink.data.dictionary.open(dictPath);
    else

        ddConnection=Simulink.data.dictionary.create(dictPath);
    end
    coder.internal.CoderDataStaticAPI.initializeDictionary(ddConnection);
    coder.internal.CoderDataStaticAPI.removeLegacyPackage(ddConnection,'Simulink');
    coder.internal.CoderDataStaticAPI.importLegacyPackage(ddConnection,packageName);
    ddConnection.saveChanges;
    ddConnection.close;
end
