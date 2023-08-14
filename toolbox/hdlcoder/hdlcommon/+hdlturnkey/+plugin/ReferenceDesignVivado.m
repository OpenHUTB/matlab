



classdef ReferenceDesignVivado<hdlturnkey.plugin.ReferenceDesign


    properties
    end

    properties(Hidden=true)



        CustomBlockDesignTcl='';


        BlockDesignName='';


        CustomTopLevelHDL='';


        VivadoBoardPart='';


        VivadoBoardName='';



        CustomUpdateProjTcl='';


        BootFromSD=false;
        RequiredFSBL='';
        RequiredUBoot='';


        IPInsertionMethod='';
        ReplacedIPInstance='';


        FilterStringCell={};


        IPCacheZipFile='';
        DisableIPCache=false;
    end

    properties(Hidden=true,Constant)

        VivadoExampleStr='hRD.addCustomVivadoDesign(''CustomBlockDesignTcl'', ''system_top.tcl'', ''VivadoBoardPart'', ''xilinx.com:zc702:part0:1.0'')';
        InterruptExampleStr='hRD.addInterruptInterface(''InterfaceID'', ''Interrupt'', ''InterruptConnection'', ''pcie2axi_bridge/INTX_MSI_Request'', ''InterruptActiveLevel'', ''High'')';
        AXI4SlaveExampleStr='hRD.addAXI4SlaveInterface(''InterfaceConnection'', ''axi_interconnect_0/M00_AXI'', ''BaseAddress'', ''0x40010000'', ''IDWidth'', 12, ''MasterAddressSpace'', ''processing_system7_0/Data'')';
        ExpectedEmbeddedCoderSupportPackage=hdlcoder.EmbeddedCoderSupportPackage.Zynq;

    end

    methods

        function obj=ReferenceDesignVivado()

            obj=obj@hdlturnkey.plugin.ReferenceDesign();

            obj.SupportedTool='Xilinx Vivado';
        end

        function addCustomVivadoDesign(obj,varargin)


            p=inputParser;
            p.addParameter('CustomBlockDesignTcl','');


            p.addParameter('VivadoBoardPart','');
            p.addParameter('CustomTopLevelHDL','');


            p.addParameter('VivadoBoardName','');

            p.parse(varargin{:});
            inputArgs=p.Results;



            hdlturnkey.plugin.validateSingleMethod(...
            obj.CustomBlockDesignTcl,'addCustomVivadoDesign()');


            hdlturnkey.plugin.validateRequiredParameter(...
            inputArgs.CustomBlockDesignTcl,'CustomBlockDesignTcl',obj.VivadoExampleStr);


            obj.CustomBlockDesignTcl=inputArgs.CustomBlockDesignTcl;

            [~,customTclFileName]=fileparts(obj.CustomBlockDesignTcl);
            obj.BlockDesignName=customTclFileName;
            obj.VivadoBoardPart=inputArgs.VivadoBoardPart;
            obj.VivadoBoardName=inputArgs.VivadoBoardName;
            obj.CustomTopLevelHDL=inputArgs.CustomTopLevelHDL;
        end

        function addInternalIOInterface(obj,varargin)



















            exampleStr='hRD.addInternalIOInterface(''InterfaceID'', ''InternalPort'', ''InterfaceType'', ''OUT'', ''PortName'', ''RefInternalIO'', ''PortWidth'', 8, ''InterfaceConnection'', ''internal_ip_0/In0''})';
            hdlturnkey.plugin.validateInternalIOInterface(...
            exampleStr,varargin{:});

            obj.addInterface(...
            hdlturnkey.interface.InterfaceInternalIOXilinx(varargin{:}));
        end

        function addAXI4StreamInterface(obj,varargin)


            obj.addInterface(hdlturnkey.interface.AXI4Stream(varargin{:}));
        end

        function addAXI4StreamVideoInterface(obj,varargin)


            obj.addInterface(hdlturnkey.interface.AXI4StreamVideo(varargin{:}));
        end

        function addAXI4MasterInterface(obj,varargin)


            obj.addInterface(hdlturnkey.interface.AXI4Master(varargin{:}));
        end

    end

    methods(Access=protected)
        function validateReferenceDesignAdditional(obj)



            hdlturnkey.plugin.validateRequiredMethod(...
            obj.CustomBlockDesignTcl,'addCustomVivadoDesign()',obj.VivadoExampleStr);


            if obj.DisableIPCache&&~isempty(obj.IPCacheZipFile)
                error(message('hdlcommon:plugin:InvalidCacheSetting'));
            end
        end
    end

    methods(Hidden=true)

        function addCustomEDKDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomEDKDesign()','Xilinx ISE','addCustomVivadoDesign()'));
        end

        function addCustomQsysDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomQsysDesign()','Altera QUARTUS II','addCustomVivadoDesign()'));
        end

        function addCustomLiberoDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomLiberoDesign()','Microchip Libero SoC','addCustomVivadoDesign()'));
        end

        function addExternalIOInterface(obj,varargin)



            exampleStr='hRD.addExternalIOInterface(''InterfaceID'', ''Push Buttons'', ''InterfaceType'', ''IN'', ''PortName'', ''PushButtons'', ''PortWidth'', 2, ''FPGAPin'', {''G19'', ''F19''}, ''IOPadConstraint'', {''IOSTANDARD = LVCMOS25''})';
            hdlturnkey.plugin.validateExternalIOInterface(...
            exampleStr,varargin{:});

            obj.addInterface(...
            hdlturnkey.interface.InterfaceExternalIO(varargin{:}));
        end

        function addInterruptInterface(obj,varargin)

            p=inputParser;
            p.addParameter('InterfaceID','');
            p.addParameter('InterruptAssertedLevel','Active-high');
            p.addParameter('InterruptConnection','');

            p.parse(varargin{:});
            inputArgs=p.Results;


            hdlturnkey.plugin.validateRequiredParameter(...
            inputArgs.InterruptConnection,'InterruptConnection',obj.InterruptExampleStr);


            obj.addInterface(hdlturnkey.interface.Interrupt(varargin{:}));

        end
    end

end


