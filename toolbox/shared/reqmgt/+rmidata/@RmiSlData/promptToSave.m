function wasSaved=promptToSave(this,modelH)
    wasSaved=false;
    if this.hasChanges(modelH)
        storageName=rmimap.StorageMapper.getInstance.getStorageFor(modelH);
        displayName=strrep(storageName,matlabroot,'...');
        if exist(storageName,'file')==2
            dlgMessage=getString(message('Slvnv:rmidata:RmiSlData:YouHaveModifiedExisting',displayName));
        else
            dlgMessage={...
            getString(message('Slvnv:rmidata:RmiSlData:YouHaveModifiedFor',get_param(modelH,'Name'))),...
            getString(message('Slvnv:rmidata:RmiSlData:YouHaveModifiedSave',displayName))};
        end
        reply=questdlg(dlgMessage,...
        getString(message('Slvnv:rmidata:RmiSlData:RequirementsLinksModified')),...
        getString(message('Slvnv:rmidata:RmiSlData:Save')),...
        getString(message('Slvnv:rmidata:RmiSlData:Discard')),...
        getString(message('Slvnv:rmidata:RmiSlData:Save')));
        if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:rmidata:RmiSlData:Save')))
            this.writeToStorage(modelH,storageName);
            wasSaved=true;
        end
    end
end
