function PopulateTraceInfo(lModelName,isSubsystemBuild)







    fileGenCfg=Simulink.fileGenControl('getConfig');
    folders=Simulink.filegen.internal.FolderConfiguration(lModelName);

    folderPath=fullfile(fileGenCfg.CodeGenFolder,folders.CodeGeneration.ModelReferenceCode,'tmwinternal');

    if(contains(folderPath,'raccel')||contains(folderPath,'modelrefsim'))
        return;
    end

    if isSubsystemBuild
        sourceSS=coder.internal.SubsystemBuild.getSourceSubsysName;
        lTopModelName=extractBefore(sourceSS,'/');
        RTWNames2SID=rtwprivate('rtwctags_registry','rtwname2sid',lModelName,lTopModelName);
    else
        RTWNames2SID=rtwprivate('rtwctags_registry','rtwname2sid',lModelName);
    end


    if~isfolder(folderPath)
        mkdir(folderPath);
    end
    mapPath=fullfile(folderPath,'BlockTraceInfo.mat');

    save(mapPath,'RTWNames2SID');
end
