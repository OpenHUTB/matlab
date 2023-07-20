function validateExternalIOInterface(exampleStr,varargin)




    p=inputParser;
    p.addParameter('InterfaceID','');
    p.addParameter('InterfaceType','');
    p.addParameter('PortName','');
    p.addParameter('PortWidth',0);
    p.addParameter('FPGAPin',{});
    p.addParameter('IOPadConstraint',{});


    p.addParameter('IsRequired',false);

    p.parse(varargin{:});
    inputArgs=p.Results;


    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.InterfaceID,'InterfaceID',exampleStr);
    hdlturnkey.plugin.validateStringProperty(...
    inputArgs.InterfaceID,'InterfaceID',exampleStr);

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.InterfaceType,'InterfaceType',exampleStr);
    hdlturnkey.plugin.validateStringProperty(...
    inputArgs.InterfaceType,'InterfaceType',exampleStr);

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.PortName,'PortName',exampleStr);
    hdlturnkey.plugin.validateStringProperty(...
    inputArgs.PortName,'PortName',exampleStr);

    hdlturnkey.plugin.validateIntegerProperty(...
    inputArgs.PortWidth,'PortWidth',exampleStr);

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.FPGAPin,'FPGAPin',exampleStr);
    hdlturnkey.plugin.validateCellProperty(...
    inputArgs.FPGAPin,'FPGAPin',exampleStr);

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.IOPadConstraint,'IOPadConstraint',exampleStr);


    hdlturnkey.plugin.validateInterfaceWidth(...
    inputArgs.InterfaceID,inputArgs.PortWidth,inputArgs.PortName);
    hdlturnkey.plugin.validateFPGAPinCount(...
    inputArgs.InterfaceID,inputArgs.FPGAPin,inputArgs.PortName,inputArgs.PortWidth);

end