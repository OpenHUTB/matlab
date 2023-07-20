function supportPackageInstaller()













    import matlab.internal.lang.capability.Capability;
    Capability.require(Capability.LocalClient);

    import matlab.addons.supportpackage.internal.explorer.*;
    showAllHardwareSupportPackages('supportPackageInstaller');
end