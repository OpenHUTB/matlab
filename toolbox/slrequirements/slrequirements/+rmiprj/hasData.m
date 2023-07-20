function yesno=hasData(fPath)




    fPath=convertStringsToChars(fPath);
    [fDir,fName,ext]=fileparts(fPath);
    ext=lower(ext);

    switch ext
    case '.m'



        docs=rmiml.getLinkedItems(fPath);
        yesno=~isempty(docs);

    case{'.mdl','.slx'}


        load_system(fPath);

        yesno=rmisl.modelHasReqLinks(get_param(fName,'Handle'));

    otherwise



        storageMapHelper=rmimap.StorageMapper.getInstance();
        reqFile=storageMapHelper.getStorageFor(fPath);
        yesno=(exist(reqFile,'file')==2);

        if~yesno

            possibleOlderFilenames=rmimap.StorageMapper.getInstance.legacyLinkPaths(fDir,fName,ext);
            for i=1:numel(possibleOlderFilenames)
                if exist(possibleOlderFilenames{i},'file')==2
                    yesno=true;
                    return;
                end
            end



            legacyReqFile=rmimap.StorageMapper.legacyReqPath(fDir,fName,ext);
            yesno=(exist(legacyReqFile,'file')==2);
        end
    end
end

