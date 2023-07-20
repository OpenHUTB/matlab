


function startConfig(name)

    ProductCatalogFile=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
    'PassenferCar.xlsx');
    Config=VirtualAssembly.VirtualAssemblyConfig('PassengerCar',...
    'ProductCatalog','',...
    'ProductCatalogFile',ProductCatalogFile);


    switch(lower(name))
    case 'hevp0'
        Config.selectFeatureVariant({'Powertrain Layout','Hybrid Electric Vehicle P0'});
        Config.setConfigModelName('HEVP0');
    case 'hevp1'
        Config.selectFeatureVariant({'Powertrain Layout','Hybrid Electric Vehicle P1'});
        Config.setConfigModelName('HEVP1');
    case 'hevp2'
        Config.selectFeatureVariant({'Powertrain Layout','Hybrid Electric Vehicle P2'});
        Config.setConfigModelName('HEVP2');
    case 'hevp3'
        Config.selectFeatureVariant({'Powertrain Layout','Hybrid Electric Vehicle P3'});
        Config.setConfigModelName('HEVP3');
    case 'hevp4'
        Config.selectFeatureVariant({'Powertrain Layout','Hybrid Electric Vehicle P4'});
        Config.setConfigModelName('HEVP4');
    case 'ev'
        Config.selectFeatureVariant({'Powertrain Layout','Electric Vehicle'});
        Config.setConfigModelName('EV');

    otherwise
        Config.selectFeatureVariant({'Powertrain Layout','Hybrid Electric Vehicle P0'});
        Config.setConfigModelName('HEVP0');
    end

    Config.generateVirtualVehicleModel();

end