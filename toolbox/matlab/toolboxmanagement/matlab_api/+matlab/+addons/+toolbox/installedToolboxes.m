function toolboxes=installedToolboxes

    toolboxes=struct([]);

    try
        installedAddonCollection=com.mathworks.toolboxmanagement.util.ManagerUtils.getInstalledAddonsForToolboxesFromCache;
        installedAddonArray=installedAddonCollection.toArray;

        for index=1:size(installedAddonArray,1)
            toolboxes(index).Name=char(installedAddonArray(index).getName);
            toolboxes(index).Version=char(installedAddonArray(index).getVersion);
            toolboxes(index).Guid=char(installedAddonArray(index).getIdentifier);
        end

    catch ex
        error(ex.message);
    end

end

