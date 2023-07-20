



function Output=readConstraints

    VehicleClassName='PassengerCar';
    ProductCatalogFile=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
    [VehicleClassName,'.xlsx']);

    ModelFile=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
    'projectsrc','VirtualVehicle','System','VirtualVehicleTemplate.slx');

    Output=VirtualAssembly.buildConstraints(ModelFile,ProductCatalogFile);

end