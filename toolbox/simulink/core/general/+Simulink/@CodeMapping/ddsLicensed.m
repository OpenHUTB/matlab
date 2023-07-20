function islicensed=ddsLicensed()




    islicensed=~isempty(which('dds.internal.isInstalledAndLicensed'))&&...
    dds.internal.isInstalledAndLicensed();
end
