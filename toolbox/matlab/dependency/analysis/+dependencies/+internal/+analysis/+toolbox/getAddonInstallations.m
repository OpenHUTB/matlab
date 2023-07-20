function addons=getAddonInstallations()
    addons=convertContainedStringsToChars(matlab.internal.addons.getAddonInstallations);
end
