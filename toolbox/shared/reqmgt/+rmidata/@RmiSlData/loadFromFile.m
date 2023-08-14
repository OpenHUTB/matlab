function loadFromFile(this,modelH)


    hasLoadedData=this.hasData(modelH);
    if hasLoadedData
        prevStorage=rmimap.StorageMapper.getInstance.getStorageFor(modelH);
    else
        prevStorage='';
    end

    if~isempty(prevStorage)&&this.hasChanges(modelH)
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
            this.writeToStorage(modelH,prevStorage);
        end
    end



    fileToLoadFrom=rmimap.StorageMapper.getInstance.promptForReqFile(modelH,true);
    if~isempty(fileToLoadFrom)
        if hasLoadedData
            modelName=get_param(modelH,'Name');
            this.repository.removeRoot(modelName,true);
        end
        [success,msg]=this.load(modelH,fileToLoadFrom);
        if success
            if isempty(prevStorage)

                rmidata.storageModeCache('set',modelH,true);
            end
        else
            errordlg(msg,...
            getString(message('Slvnv:rmidata:RmiSlData:ErrorLoadingFromFile')),...
            'modal');


            if~strcmp(fileToLoadFrom,prevStorage)
                rmimap.StorageMapper.getInstance.forget(modelH,false);
                if~isempty(prevStorage)
                    this.load(modelH,prevStorage);
                end
            end
        end
    end
end
