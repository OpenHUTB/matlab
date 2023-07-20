function ddConn=checkAndCreateDD(dictionaryName)





    ddConn=[];
    if isempty(dictionaryName)
        return;
    end

    if~exist(dictionaryName,'file')
        ddConn=Simulink.data.dictionary.create(dictionaryName);
        msg=DAStudio.message('autosarstandard:importer:newDataDictionaryCreated',dictionaryName);
        autosar.mm.util.MessageReporter.print(msg);
    else
        ddConn=Simulink.data.dictionary.open(dictionaryName);
    end
