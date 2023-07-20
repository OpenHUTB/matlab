function loadFromFile(modelH)


    hasLoadedData=rmidata.bdHasExternalData(modelH,false);
    if hasLoadedData
        prevStorage=rmimap.StorageMapper.getInstance.getStorageFor(modelH);
    else
        prevStorage='';
    end

    if~isempty(prevStorage)&&slreq.hasChanges(modelH)
        reply=questdlg({...
        getString(message('Slvnv:rmidata:RmiSlData:LoadedLinksHaveChanges')),...
        getString(message('Slvnv:rmidata:RmiSlData:SaveToQuest',prevStorage))},...
        getString(message('Slvnv:rmidata:RmiSlData:RequirementsUnsavedChanges')),...
        getString(message('Slvnv:rmidata:RmiSlData:Save')),...
        getString(message('Slvnv:rmidata:RmiSlData:Discard')),...
        getString(message('Slvnv:rmidata:RmiSlData:Cancel')),...
        getString(message('Slvnv:rmidata:RmiSlData:Cancel')));
        if isempty(reply)||strcmp(reply,getString(message('Slvnv:rmidata:RmiSlData:Cancel')))
            return;
        elseif strcmp(reply,getString(message('Slvnv:rmidata:RmiSlData:Save')))
            rmidata.save(modelH,prevStorage);
        end
    end



    fileToLoadFrom=rmimap.StorageMapper.getInstance.promptForReqFile(modelH,true);
    if~isempty(fileToLoadFrom)

        modelPath=get_param(modelH,'FileName');

        if hasLoadedData

            dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(modelPath);
            if~isempty(dataLinkSet)&&slreq.internal.isSharedSlreqInstalled()
                slreq.linkmgr.LinkSetManager.getInstance.clearAllReferencesForLinkSet(dataLinkSet);
            end
            slreq.discardLinkSet(modelPath);
        end

        success=slreq.utils.loadLinkSet(modelPath,true);
        if success
            msg='';
            if strcmp(get_param(modelH,'ReqHilite'),'on')
                rmisl.highlight(modelH,true);
            end
        elseif exist(fileToLoadFrom,'file')==2
            [~,fName,fExt]=fileparts(fileToLoadFrom);
            [~,mName,mExt]=fileparts(modelPath);
            msg=getString(message('Slvnv:rmidata:RmiSlData:FailedToLoadFor',[fName,fExt],[mName,mExt]));
        else
            msg=getString(message('Slvnv:slreq:MissingDataFile',fileToLoadFrom));
        end

        if success
            if isempty(prevStorage)

                rmidata.storageModeCache('set',modelH,true);
            end

        else
            errordlg(msg,...
            getString(message('Slvnv:rmidata:RmiSlData:ErrorLoadingFromFile')),...
            'modal');

            if~isempty(prevStorage)

                if~strcmp(fileToLoadFrom,prevStorage)
                    rmimap.StorageMapper.getInstance.forget(modelH,false);
                    if~isempty(prevStorage)
                        rmimap.map(modelPath,prevStorage);
                        slreq.utils.loadLinkSet(modelPath,true);
                    end
                end
            end
        end
    end
end
