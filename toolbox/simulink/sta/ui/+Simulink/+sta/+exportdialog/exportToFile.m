function[gotExported,errMsg]=exportToFile(sigIDs,fileToSave,isAppend)



    repoUtil=starepository.RepositoryUtility;


    Signals=getSignalValuesAndNames(repoUtil,sigIDs);


    aMatFile=iofile.STAMatFile();

    [~,~,fileExt]=fileparts(fileToSave);


    if isempty(fileExt)||~strcmpi(fileExt,'.mat')
        fileToSave=[fileToSave,'.mat'];
    end


    [gotExported,errMsg]=export(aMatFile,fileToSave,Signals.Names,Signals.Data,isAppend);