function yesno=promptToSave(fPath)





    storageName=rmimap.StorageMapper.getInstance.getStorageFor(fPath);
    displayName=strrep(storageName,matlabroot,'...');
    reply=questdlg(getString(message('Slvnv:rmide:YouHaveModified',displayName)),...
    getString(message('Slvnv:rmide:RequirementsLinksModified')),...
    getString(message('Slvnv:rmide:Save')),...
    getString(message('Slvnv:rmide:Discard')),...
    getString(message('Slvnv:rmide:Save')));
    yesno=~isempty(reply)&&strcmp(reply,getString(message('Slvnv:rmide:Save')));

end

