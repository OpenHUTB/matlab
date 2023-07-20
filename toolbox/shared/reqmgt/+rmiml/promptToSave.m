function yesno=promptToSave(fPath,reloadingFrom)
    if nargin<2
        reloadingFrom='';
    end

    storageName=rmimap.StorageMapper.getInstance.getStorageFor(fPath);
    displayName=strrep(storageName,matlabroot,'...');
    displayPath=strrep(fPath,matlabroot,'...');
    if exist(storageName,'file')==2
        dlgMessage=getString(message('Slvnv:rmiml:YouHaveModifiedExisting',displayName));
    elseif~isempty(reloadingFrom)
        dlgMessage={...
        getString(message('Slvnv:rmiml:YouHaveModifiedFor',displayPath)),...
        getString(message('Slvnv:rmiml:YouHaveModifiedReloading',reloadingFrom))};
    else
        dlgMessage={...
        getString(message('Slvnv:rmiml:YouHaveModifiedFor',displayPath)),...
        getString(message('Slvnv:rmiml:YouHaveModifiedSave',displayName))};
    end
    reply=questdlg(dlgMessage,...
    getString(message('Slvnv:rmiml:RequirementsLinksModified')),...
    getString(message('Slvnv:rmiml:Save')),...
    getString(message('Slvnv:rmiml:Discard')),...
    getString(message('Slvnv:rmiml:Save')));

    yesno=~isempty(reply)&&strcmp(reply,getString(message('Slvnv:rmiml:Save')));
end

