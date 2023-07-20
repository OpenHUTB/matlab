function was_successful_struct=cb_ExportOk(State)





    was_successful_struct.was_successful=false;
    was_successful_struct.errMsg='';

    fullFilePath=State.fileName;

    try
        aFileObj=Simulink.io.FileTypeFactory.getInstance().createReader(fullFilePath,State.readerName);

        repoUtil=starepository.RepositoryUtility;


        Signals=getSignalValuesAndNames(repoUtil,State.idsToExport);


        [didWrite,errMsg]=export(aFileObj,fullFilePath,Signals.Names,Signals.Data,State.isAppend);

        was_successful_struct.errMsg=errMsg;
        was_successful_struct.was_successful=didWrite;

    catch ME_EXPORT

        was_successful_struct.errMsg=ME_EXPORT.message;
        was_successful_struct.was_successful=false;
        return;
    end