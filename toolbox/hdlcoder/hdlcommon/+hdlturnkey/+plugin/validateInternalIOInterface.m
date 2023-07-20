function validateInternalIOInterface(exampleStr,varargin)




    p=inputParser;
    p.addParameter('InterfaceID','');
    p.addParameter('InterfaceType','');
    p.addParameter('PortName','');
    p.addParameter('PortWidth',0);
    p.addParameter('InterfaceConnection','');


    p.addParameter('IsRequired',true);

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


    hdlturnkey.plugin.validatePropertyValue(...
    inputArgs.InterfaceType,'InterfaceType',{'IN','OUT'});

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.PortName,'PortName',exampleStr);
    hdlturnkey.plugin.validateStringProperty(...
    inputArgs.PortName,'PortName',exampleStr);

    hdlturnkey.plugin.validateIntegerProperty(...
    inputArgs.PortWidth,'PortWidth',exampleStr);

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.InterfaceConnection,'InterfaceConnection',exampleStr);
    hdlturnkey.plugin.validateStringProperty(...
    inputArgs.InterfaceConnection,'InterfaceConnection',exampleStr);

end