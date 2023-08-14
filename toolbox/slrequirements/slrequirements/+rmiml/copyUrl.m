function copyUrl(srcKey,location)




    if~rmiml.canLink(srcKey,true)
        return;
    end

    if any(location=='.')
        locationId=location;
    else
        [~,locationId]=rmiml.getBookmark(srcKey,location);
        if~any(locationId=='.')
            storageFile=rmimap.StorageMapper.getInstance.getStorageFor(srcKey);
            question={...
            getString(message('Slvnv:rmiml:NamedRangeDoesNotExist',location,srcKey)),...
            getString(message('Slvnv:rmiml:NamedRangeCreate',storageFile))};
            reply=questdlg(question,getString(message('Slvnv:rmiml:NamedRangeDlgTitle')),...
            getString(message('Slvnv:rmiml:Create')),...
            getString(message('Slvnv:rmiml:Cancel')),...
            getString(message('Slvnv:rmiml:Cancel')));
            if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:rmiml:Create')))
                [~,locationId]=rmiml.ensureBookmark(srcKey,location);
                com.mathworks.toolbox.simulink.slvnv.RmiDataLink.fireUpdateEvent(srcKey,locationId);
            else
                return;
            end
        end
    end

    cmd=sprintf('rmicodenavigate(''%s'',''%s'');',srcKey,locationId);
    rmiut.matlabConnectorOn();
    url=rmiut.cmdToUrl(cmd);
    clipboard('copy',url);

end
