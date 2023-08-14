function yesno=hasReqDataFile(fKey)

    if rmisl.isSidString(fKey)
        mdlName=strtok(fKey,':');
        if dig.isProductInstalled('Simulink')&&is_simulink_loaded()
            try
                artPath=get_param(mdlName,'FileName');
            catch ex %#ok<NASGU>


                artPath=which(mdlName);
            end
        else
            artPath=which(mdlName);
        end
        if~isempty(artPath)
            storageFile=rmimap.StorageMapper.getInstance.getStorageFor(mdlPath);
        else
            yesno=false;
            return;
        end

    else

        artPath=fKey;
        storageFile=rmimap.StorageMapper.getInstance.getStorageFor(fKey);
    end

    yesno=(exist(storageFile,'file')==2);


    if~yesno&&contains(storageFile,'.slmx')
        [artDir,artBase,artExt]=fileparts(artPath);
        legacyReqFile=rmimap.StorageMapper.legacyReqPath(artDir,artBase,artExt);
        yesno=(exist(legacyReqFile,'file')==2);
    end
end
