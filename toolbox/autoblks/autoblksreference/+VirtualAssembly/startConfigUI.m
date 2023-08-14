


function startConfigUI()

    ProductCatalogFile=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
    'PassengerCar.xlsx');
    ConfigUI=VirtualAssembly.VirtualView(...
    'ProductCatalog','',...
    'ProductCatalogFile',ProductCatalogFile);

    ConfigUI.openApp();

end