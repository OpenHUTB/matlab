function ret=isDDSApp(modelName)







    ret=~isempty(which('dds.internal.isInstalledAndLicensed'))&&...
    dds.internal.isInstalledAndLicensed('test')&&...
    dds.internal.coder.isDDSApp(modelName);
end

