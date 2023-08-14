function[isInstalled,addonID]=isOnrampAddonInstalled()




    isInstalled=false;
    addonID="03ac1c2d-358f-4fbd-969a-bed6cce06f14";
    installedToolboxes=matlab.addons.toolbox.installedToolboxes;

    if~isempty(installedToolboxes)
        guids={installedToolboxes.Guid};
        isInstalled=any(strcmp(guids,addonID));
    end
end