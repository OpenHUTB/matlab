function validateEthernetMACInterface(obj,exampleStr,varargin)





    if~strcmpi(obj.FPGAVendor,'Xilinx')
        error(message('hdlcommon:plugin:InvalidUseOfaddEthernetMACInterface',obj.BoardName));
    end

    p=inputParser;
    p.addParameter('InterfaceType','');
    p.addParameter('MACAddress','');
    p.addParameter('IPAddress','');
    p.addParameter('NumChannels',0);
    p.addParameter('PortAddresses',{});
    p.addParameter('EthernetMACConstraintFile',{});


    p.addParameter('IsRequired',false);

    p.parse(varargin{:});
    inputArgs=p.Results;

    InterfaceTypeChoices={'MII','GMII','SGMII'};


    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.MACAddress,'MACAddress',exampleStr);
    hdlturnkey.plugin.validateStringProperty(...
    inputArgs.MACAddress,'MACAddress',exampleStr);

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.InterfaceType,'InterfaceType',exampleStr);
    hdlturnkey.plugin.validatePropertyValue(...
    inputArgs.InterfaceType,'InterfaceType',InterfaceTypeChoices);

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.IPAddress,'IPAddress',exampleStr);
    hdlturnkey.plugin.validateIPAddressProperty(...
    inputArgs.IPAddress,'IPAddress',exampleStr);

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.NumChannels,'NumChannels',exampleStr);
    hdlturnkey.plugin.validateValueWithinRange(...
    inputArgs.NumChannels,'NumChannels',[1,8],exampleStr);

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.PortAddresses,'PortAddresses',exampleStr);
    hdlturnkey.plugin.validatePortAddress(...
    inputArgs.PortAddresses,'PortAddresses',inputArgs.NumChannels,exampleStr);

    hdlturnkey.plugin.validateRequiredParameter(...
    inputArgs.EthernetMACConstraintFile,'EthernetMACConstraintFile',exampleStr);
    hdlturnkey.plugin.validateStringProperty(...
    inputArgs.EthernetMACConstraintFile,'EthernetMACConstraintFile',exampleStr);

end