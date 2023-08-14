



classdef ReferenceDesignLibero<hdlturnkey.plugin.ReferenceDesign


    properties
    end

    properties(Hidden=true)



        CustomBlockDesignTcl='';


        BlockDesignName='';


        CustomMSSConfig={};
        CustomMSSCxfFile={};
        CustomMSSSdbFile={};




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

        LiberoExampleStr='hRD.addCustomLiberoDesign(''CustomBlockDesignTcl'', ''design1_led.tcl'')';
        AXI4SlaveExampleStr='hRD.addAXI4SlaveInterface(''InterfaceConnection'', ''COREAXI4INTERCONNECT_C0_0/AXI4mslave0'', ''BaseAddress'', ''0x00000000'', ''IDWidth'', 12)';
        ExpectedEmbeddedCoderSupportPackage=hdlcoder.EmbeddedCoderSupportPackage.Zynq;

    end

    methods

        function obj=ReferenceDesignLibero()

            obj=obj@hdlturnkey.plugin.ReferenceDesign();

            obj.SupportedTool='Microchip Libero SoC';
        end

        function addCustomLiberoDesign(obj,varargin)


            p=inputParser;
            p.addParameter('CustomBlockDesignTcl','');

            p.parse(varargin{:});
            inputArgs=p.Results;



            hdlturnkey.plugin.validateSingleMethod(...
            obj.CustomBlockDesignTcl,'addCustomLiberoDesign()');


            hdlturnkey.plugin.validateRequiredParameter(...
            inputArgs.CustomBlockDesignTcl,'CustomBlockDesignTcl',obj.LiberoExampleStr);


            obj.CustomBlockDesignTcl=inputArgs.CustomBlockDesignTcl;

            [~,customTclFileName]=fileparts(obj.CustomBlockDesignTcl);
            obj.BlockDesignName=customTclFileName;
        end

        function addCustomMSSConfig(obj,varargin)


            p=inputParser;
            p.addParameter('CustomMSSConfig','');

            p.parse(varargin{:});
            inputArgs=p.Results;



            hdlturnkey.plugin.validateSingleMethod(...
            obj.CustomMSSConfig,'addCustomMSSConfig()');


            hdlturnkey.plugin.validateRequiredParameter(...
            inputArgs.CustomMSSConfig,'CustomMSSConfig',obj.LiberoExampleStr);


            obj.CustomMSSConfig=inputArgs.CustomMSSConfig;
        end

        function addCustomComponentFiles(obj,varargin)
            p=inputParser;


            p.addParameter('CustomMSSCxfFile','');
            p.addParameter('CustomMSSSdbFile','');


            p.parse(varargin{:});
            inputArgs=p.Results;



            hdlturnkey.plugin.validateSingleMethod(...
            obj.CustomMSSCxfFile,'addCustomComponentFiles()');

            obj.CustomMSSCxfFile=inputArgs.CustomMSSCxfFile;
            obj.CustomMSSSdbFile=inputArgs.CustomMSSSdbFile;
        end

        function addInternalIOInterface(obj,varargin)



















            exampleStr='hRD.addInternalIOInterface(''InterfaceID'', ''InternalPort'', ''InterfaceType'', ''OUT'', ''PortName'', ''RefInternalIO'', ''PortWidth'', 8, ''InterfaceConnection'', ''internal_ip_0/In0''})';
            hdlturnkey.plugin.validateInternalIOInterface(...
            exampleStr,varargin{:});

            obj.addInterface(...
            hdlturnkey.interface.InterfaceInternalIOLiberoSoC(varargin{:}));
        end

        function addAXI4MasterInterface(obj,varargin)


            obj.addInterface(hdlturnkey.interface.AXI4Master(varargin{:}));
        end

    end

    methods(Access=protected)
        function validateReferenceDesignAdditional(obj)



            hdlturnkey.plugin.validateRequiredMethod(...
            obj.CustomBlockDesignTcl,'addCustomLiberoDesign()',obj.LiberoExampleStr);


            if obj.DisableIPCache&&~isempty(obj.IPCacheZipFile)
                error(message('hdlcommon:plugin:InvalidCacheSetting'));
            end
        end
    end

    methods(Hidden=true)

        function addCustomEDKDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomEDKDesign()','Xilinx ISE','addCustomLiberoDesign()'));
        end

        function addCustomQsysDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomQsysDesign()','Altera QUARTUS II','addCustomLiberoDesign()'));
        end

        function addCustomVivadoDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomVivadoDesign()','Xilinx Vivado','addCustomLiberoDesign()'));

        end

        function addExternalIOInterface(obj,varargin)


            exampleStr='hRD.addExternalIOInterface(''InterfaceID'', ''Push Buttons'', ''InterfaceType'', ''IN'', ''PortName'', ''PushButtons'', ''PortWidth'', 2, ''FPGAPin'', {''J25'', ''H25''},''IOPadConstraint'', {''IOSTANDARD = LVCMOS25''})';
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
