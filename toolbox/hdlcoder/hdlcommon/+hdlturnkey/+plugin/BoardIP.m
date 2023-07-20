




classdef BoardIP<hdlturnkey.PluginBoard


    properties


        SupportedTool={};






        JTAGChainPosition=2;


        ExternalMemorySize double{mustBeNonnegative}=0;
        SharedMemorySize double{mustBeNonnegative}=0;


        HasEthernetMAC=false;

        InterfaceType='GMII';
        MACAddress='0x000A3502218A';
        IPAddress='192.168.0.2';
        NumChannels=8;
        PortAddresses=[50101,50102,50103,50104,50105,50106,50107,50108];
        EthernetMACConstraintFile='';

        isEthernetConnected=false;
    end

    properties(Hidden)
        IRLengthBefore double{mustBeNonnegative}=[];
        IRLengthAfter double{mustBeNonnegative}=[];
    end

    properties(GetAccess=public,SetAccess=protected,Hidden)


        isGenericIPPlatform=false;
    end

    methods

        function obj=BoardIP(isGeneric)

            obj=obj@hdlturnkey.PluginBoard();


            if nargin>0
                obj.isGenericIPPlatform=isGeneric;
            end
        end

        function set.SupportedTool(obj,tool)

            obj.RequiredTool=tool;
            obj.SupportedTool=tool;
        end

        function addInterface(obj,hInterface)
            if obj.isGenericIPPlatform
                hInterface.IsGenericIP=true;
            end

            addInterface@hdlturnkey.PluginBoard(obj,hInterface);
        end

        function addExternalIOInterface(obj,varargin)



            exampleStr='hB.addExternalIOInterface(''InterfaceID'', ''Push Buttons'', ''InterfaceType'', ''IN'', ''PortName'', ''PushButtons'', ''PortWidth'', 2, ''FPGAPin'', {''G19'', ''F19''}, ''IOPadConstraint'', {''IOSTANDARD = LVCMOS25''})';
            hdlturnkey.plugin.validateExternalIOInterface(...
            exampleStr,varargin{:});

            obj.addInterface(...
            hdlturnkey.interface.InterfaceExternalIO(varargin{:}));
        end
        function addEthernetMACInterface(obj,varargin)
            p=inputParser;


            p.addParameter('InterfaceType','GMII');
            p.addParameter('MACAddress','0x000A3502218A');
            p.addParameter('IPAddress','192.168.0.2');
            p.addParameter('NumChannels',2);
            p.addParameter('PortAddresses',[50101,50102]);
            p.addParameter('EthernetMACConstraintFile','');

            p.parse(varargin{:});
            inputArgs=p.Results;


            exampleStr=['hB.addEthernetMACInterface(''InterfaceType'',''GMII'','...
            ,'''MACAddress'',''0x000A3502218A'','...
            ,'''IPAddress'', ''192.168.0.2'','...
            ,'''NumChannels'', 2 ,'...
            ,'''PortAddresses'',[50101, 50102],'...
            ,'''EthernetMACConstraintFile'' ,''../contarintFile.xdc'')'];
            hdlturnkey.plugin.validateEthernetMACInterface(obj,...
            exampleStr,varargin{:});

            obj.InterfaceType=inputArgs.InterfaceType;
            obj.MACAddress=inputArgs.MACAddress;
            obj.IPAddress=inputArgs.IPAddress;
            obj.NumChannels=inputArgs.NumChannels;
            obj.EthernetMACConstraintFile=inputArgs.EthernetMACConstraintFile;
            obj.PortAddresses=inputArgs.PortAddresses;

            obj.HasEthernetMAC=true;
        end

        function status=hasEthernetMAC(obj)

            status=obj.HasEthernetMAC;
        end

        function addExternalPortInterface(obj,varargin)


            p=inputParser;
            p.addParameter('IOPadConstraint',{});
            p.parse(varargin{:});
            inputArgs=p.Results;



            hdlturnkey.plugin.validateSingleMethod(...
            obj.DefaultIOPadConstrain,'addExternalPortInterface()');


            exampleStr='hB.addExternalPortInterface(''IOPadConstraint'', {''IO_STANDARD "2.5V"''})';
            hdlturnkey.plugin.validateRequiredParameter(...
            inputArgs.IOPadConstraint,'IOPadConstraint',exampleStr);


            obj.DefaultIOPadConstrain=inputArgs.IOPadConstraint;

            obj.addInterface(hdlturnkey.interface.InterfaceExternal());
        end

        function validateBoard(obj)



            hdlturnkey.plugin.validateRequiredStringProperty(...
            obj.BoardName,'BoardName',...
            'hB.BoardName = ''My custom board''');


            hdlturnkey.plugin.validateRequiredStringProperty(...
            obj.FPGAVendor,'FPGAVendor',...
            'hB.FPGAVendor = ''Xilinx''');
            hdlturnkey.plugin.validatePropertyValue(...
            obj.FPGAVendor,'FPGAVendor',{'Xilinx','Altera','Microchip'});


            hdlturnkey.plugin.validateRequiredStringProperty(...
            obj.FPGAFamily,'FPGAFamily',...
            'hB.FPGAFamily = ''Zynq''');
            hdlturnkey.plugin.validateRequiredStringProperty(...
            obj.FPGADevice,'FPGADevice',...
            'hB.FPGADevice = ''xc7z020''');


            hdlturnkey.plugin.validateRequiredProperty(...
            obj.SupportedTool,'SupportedTool',...
            'hB.SupportedTool = {''Xilinx Vivado''}');
            hdlturnkey.plugin.validateCellProperty(...
            obj.SupportedTool,'SupportedTool',...
            'hB.SupportedTool = {''Xilinx Vivado''}');
            hdlturnkey.plugin.validatePropertyValue(...
            obj.SupportedTool,'SupportedTool',...
            {'Xilinx Vivado','Xilinx ISE','Altera QUARTUS II','Intel Quartus Pro','Microchip Libero SoC','NI LabVIEW'});


            hdlturnkey.plugin.validateIntegerProperty(...
            obj.JTAGChainPosition,'JTAGChainPosition',...
            'hB.JTAGChainPosition = 2');


        end
    end

end

