function yesno=isSupportedSourceType(srcName)










    srcName=convertStringsToChars(srcName);

    switch exist(srcName,'file')
    case 2
        [~,~,ext]=fileparts(srcName);
        yesno=any(strcmp(ext,{'.m','.sldd','.mldatx'}));
    case 4

        [~,mdlName]=fileparts(srcName);
        if rmisl.isSimulinkModelLoaded(mdlName)
            yesno=rmidata.isExternal(mdlName);
        else

            fullPathToModel=which(srcName);
            rmiDataPath=rmimap.StorageMapper.getInstance.getStorageFor(fullPathToModel);
            yesno=(exist(rmiDataPath,'file')==2);
        end
    otherwise
        yesno=false;
    end
end
