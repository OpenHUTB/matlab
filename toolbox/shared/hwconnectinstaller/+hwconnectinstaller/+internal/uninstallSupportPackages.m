function uninstallSupportPackages(spPkgs)







    validateattributes(spPkgs,{'hwconnectinstaller.SupportPackage'},{},'uninstallSupportPackages','spPkgs');


    spPkgs={spPkgs.Name};


    hInstaller=hwconnectinstaller.PackageInstaller;
    for i=1:numel(spPkgs)
        try
            hInstaller.uninstallRecursive(spPkgs{i},...
            true,...
            true,...
            struct('uninstallErrorAction','continue'));
        catch ex


        end
    end
