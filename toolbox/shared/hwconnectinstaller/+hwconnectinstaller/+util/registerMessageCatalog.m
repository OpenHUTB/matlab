function registerMessageCatalog(spPkg)







    validateattributes(spPkg,{'char','hwconnectinstaller.SupportPackage'},...
    {'nonempty'},'registerMessageCatalog','spPkg');

    hwconnectinstaller.util.registerInstalledMessageCatalogs();

end
