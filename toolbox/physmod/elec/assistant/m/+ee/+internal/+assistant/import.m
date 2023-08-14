function importedStatus=import(modelName,outputDirectory)




















    if~exist('modelName','var')
        modelName=bdroot;

        if strcmp('power_utile',modelName)
            bdclose('power_utile');
            modelName=bdroot;
        end
    end

    if isempty(modelName)
        error('Function ee.internal.assistant.import is for internal use only.');
    end


    m=ee.internal.assistant.Model(modelName);

    if exist('outputDirectory','var')
        m.OutputDirectory=outputDirectory;
        m.OutputDirectorySpecified=true;
    end


    m.enableSummary;
    m.import;
    if m.ImportedStatus==true
        m.publishSummary;
    end
    importedStatus=m.ImportedStatus;


    if strcmp('Open',m.InitialState)
        m.openImportedModel;
        m.openSummary;
    end

end