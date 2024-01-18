function result=showNoLinksDlg(modelH,dlgTitle,storageLocation,usingDefault)

    modelName=get_param(modelH,'Name');
    isLibrary=strcmp(get_param(modelH,'BlockDiagramType'),'library');

    if rmidata.isExternal(modelH)
        if nargin==2
            [storageLocation,usingDefault]=rmimap.StorageMapper.getInstance.getStorageFor(modelH);
        end
        if~usingDefault&&exist(storageLocation,'file')~=2
            dlgTitle=getString(message('Slvnv:reqmgt:requirementsFileNotFound'));
            if isLibrary
                associatedWithMessage=getString(message('Slvnv:reqmgt:NoLinksDlgLibraryWasAssociatedWith',modelName));
            else
                associatedWithMessage=getString(message('Slvnv:reqmgt:NoLinksDlgModelWasAssociatedWith',modelName));
            end
            missingFileMessage={...
            associatedWithMessage,...
            [storageLocation,'.'],...
            getString(message('Slvnv:reqmgt:NoLinksDlgReqFileNotFound'))};
            if nargin==2
                missingFileMessage{end+1}=getString(message('Slvnv:reqmgt:NoLinksDlgYouMayBrowse'));
                reply=questdlg(missingFileMessage,...
                dlgTitle,...
                getString(message('Slvnv:reqmgt:OK')),...
                getString(message('Slvnv:reqmgt:Browse')),...
                getString(message('Slvnv:reqmgt:OK')));
                if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:reqmgt:Browse')))
                    rmidata.loadFromFile(modelH);
                end
            else
                msgbox(missingFileMessage,dlgTitle,'modal');
            end
            result=false;
            return;
        else
            storageLocation=strrep(storageLocation,[matlabroot,filesep],'...');
            storageLocation=strrep(storageLocation,['...toolbox',filesep],'...');
            if isLibrary
                no_reqs_message={getString(message('Slvnv:reqmgt:NoLinksDlgLibraryHasNoLinksIn',modelName)),...
                [storageLocation,'.']};
            else
                no_reqs_message={getString(message('Slvnv:reqmgt:NoLinksDlgModelHasNoLinksIn',modelName)),...
                [storageLocation,'.']};
            end
        end
    else
        if isLibrary
            no_reqs_message={getString(message('Slvnv:reqmgt:NoLinksDlgLibraryHasNoLinks',modelName))};
        else
            no_reqs_message={getString(message('Slvnv:reqmgt:NoLinksDlgModelHasNoLinks',modelName))};
        end
    end
    filterSettings=rmi.settings_mgr('get','filterSettings');
    if filterSettings.enabled&&(~isempty(filterSettings.tagsRequire)||~isempty(filterSettings.tagsExclude))
        no_reqs_message{end+1}=getString(message('Slvnv:reqmgt:NoLinksDlgOrNoTagMatch'));
    end
    helpdlg(no_reqs_message,dlgTitle);

    result=true;
end
