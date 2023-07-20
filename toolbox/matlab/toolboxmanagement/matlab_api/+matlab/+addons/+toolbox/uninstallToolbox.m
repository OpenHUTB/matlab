function uninstallToolbox(installedToolbox)

    narginchk(1,1);
    import com.mathworks.addons_common.notificationframework.InstalledAddOnsCache;

    validateattributes(installedToolbox,{'struct'},{'scalar'},...
    'matlab.addons.toolbox.uninstallToolbox','InstalledToolbox',1)

    fieldsExist=isfield(installedToolbox,{'Guid','Version'});
    if~(fieldsExist(1)&&fieldsExist(2))
        error(message('toolboxmanagement_matlab_api:uninstallToolbox:invalidInputStruct'));
    end

    toolboxGuid=installedToolbox.Guid;
    toolboxVersion=installedToolbox.Version;

    try
        addOnsInstallationFolder=java.io.File(matlab.internal.addons.util.retrieveAddOnsInstallationFolder).toPath;
        installedAddOnsCache=InstalledAddOnsCache.getInstance;
        if~installedAddOnsCache.hasAddonWithIdentifierAndVersion(toolboxGuid,toolboxVersion)
            warning(message('toolboxmanagement_matlab_api:uninstallToolbox:toolboxNotFound'));
        else
            installedAddon=installedAddOnsCache.retrieveAddOnWithIdentifierAndVersion(toolboxGuid,toolboxVersion);
            toolboxInstallationFolder=installedAddon.getInstalledFolder;
            toolboxName=installedAddon.getName;


            if matlab.addons.isAddonEnabled(toolboxGuid,toolboxVersion)
                matlab.addons.disableAddon(toolboxGuid,toolboxVersion);
            end


            appsToUninstall=installedAddon.getRelatedAddOnIdentifiers;
            for appUninstallCounter=1:size(appsToUninstall)
                appGuid=appsToUninstall(appUninstallCounter);
                installedAppMetadatas=com.mathworks.appmanagement.MlappinstallUtil.getInstalledApps;
                for installedAppMetadatasCounter=1:size(installedAppMetadatas)
                    if strcmp(installedAppMetadatas(installedAppMetadatasCounter).getGuid,appGuid)==1
                        if installedAddOnsCache.hasAddonWithIdentifier(appGuid)
                            installedApp=installedAddOnsCache.retrieveAddOnWithIdentifier(appGuid);
                            matlab.internal.addons.registry.removeAddOn(string(appGuid),string(installedApp.getVersion));
                            com.mathworks.addons_common.notificationframework.AddonManagement.uninstallFromMatlabAPI(appGuid,installedApp.getVersion);
                        end
                    end
                end
            end

            manager=com.mathworks.toolboxmanagement.CustomToolboxManager;
            matlab.internal.addons.registry.removeAddOn(string(installedAddon.getIdentifier),string(installedAddon.getVersion));
            uninstallCompletionStatus=manager.uninstallFromMatlabAPI(addOnsInstallationFolder,toolboxInstallationFolder);

            if uninstallCompletionStatus~=com.mathworks.toolboxmanagement.UninstallCompletionStatus.SUCCESS
                if uninstallCompletionStatus==com.mathworks.toolboxmanagement.UninstallCompletionStatus.MANUAL_CLEANUP_NEEDED
                    warning(message('toolboxmanagement_matlab_api:uninstallToolbox:manualCleanupNeeded',char(toolboxInstallationFolder.toString)));
                elseif uninstallCompletionStatus==com.mathworks.toolboxmanagement.UninstallCompletionStatus.LOCKED_JAR
                    warning(message('toolboxmanagement_matlab_api:uninstallToolbox:lockedJar',char(toolboxInstallationFolder.toString)));
                else
                    error(char(uninstallCompletionStatus.getMessage(toolboxName)));
                end
            else
                com.mathworks.addons_common.notificationframework.AddonManagement.removeFolder(toolboxInstallationFolder,installedAddon);
            end
        end

    catch ex
        error(ex.message);
    end

end
