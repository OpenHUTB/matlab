



classdef ReferenceDesignEDK<hdlturnkey.plugin.ReferenceDesign


    properties
    end

    properties(Hidden=true)



        CustomEDKMHS='';


        RequiredEDKFolder='';
        RequiredEDKFiles={};


        BootFromSD=false;
        RequiredFSBL='';
        RequiredUBoot='';


        IPInsertionMethod='';
        ReplacedIPName='';
        ReplacedIPInstance='';


        AXILite_Name='';
        AXILite_BaseAddr='';
        AXILite_HighAddr='';
        AXI_CLK='';
        AXIStreamVideoIn_Name='';
        AXIStreamVideoOut_Name='';


        FilterStringCell={};


    end

    properties(Hidden=true,Constant)

        EDKExampleStr='hRD.addCustomEDKDesign(''CustomEDKMHS'', ''system.mhs'')';
        AXI4SlaveExampleStr='hRD.addAXI4SlaveInterface(''InterfaceConnection'', ''axi_interconnect_0/M00_AXI'', ''BaseAddress'', ''0x40010000'', ''IDWidth'', ''12'')';
        ExpectedEmbeddedCoderSupportPackage=hdlcoder.EmbeddedCoderSupportPackage.Zynq;

    end

    methods

        function obj=ReferenceDesignEDK()

            obj=obj@hdlturnkey.plugin.ReferenceDesign();

            obj.SupportedTool='Xilinx ISE';
        end

        function addCustomEDKDesign(obj,varargin)


            p=inputParser;
            p.addParameter('CustomEDKMHS','');

            p.parse(varargin{:});
            inputArgs=p.Results;



            hdlturnkey.plugin.validateSingleMethod(...
            obj.CustomEDKMHS,'addCustomEDKDesign()');


            hdlturnkey.plugin.validateRequiredParameter(...
            inputArgs.CustomEDKMHS,'CustomEDKMHS',obj.EDKExampleStr);


            obj.CustomEDKMHS=inputArgs.CustomEDKMHS;
        end

        function addInternalIOInterface(obj,varargin)



















            exampleStr='hRD.addInternalIOInterface(''InterfaceID'', ''InternalPort'', ''InterfaceType'', ''OUT'', ''PortName'', ''RefInternalIO'', ''PortWidth'', 8, ''InterfaceConnection'', ''internal_ip_In0''})';
            hdlturnkey.plugin.validateInternalIOInterface(...
            exampleStr,varargin{:});

            obj.addInterface(...
            hdlturnkey.interface.InterfaceInternalIOXilinx(varargin{:}));
        end

        function addAXI4MasterInterface(obj,varargin)


            error(message('hdlcommon:plugin:InterfaceNotSupportedByTool',...
            'AXI4 Master','Xilinx ISE'));
        end

    end

    methods(Access=protected)
        function validateReferenceDesignAdditional(obj)



            hdlturnkey.plugin.validateRequiredMethod(...
            obj.CustomEDKMHS,'addCustomEDKDesign()',obj.EDKExampleStr);
        end
    end

    methods(Hidden=true)

        function addCustomVivadoDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomVivadoDesign()','Xilinx Vivado','addCustomEDKDesign()'));
        end

        function addCustomQsysDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomQsysDesign()','Altera QUARTUS II','addCustomEDKDesign()'));
        end

        function addCustomLiberoDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomLiberoDesign()','Microchip Libero SoC','addCustomEDKDesign()'));
        end

        function addExternalIOInterface(obj,varargin)



            exampleStr='hRD.addExternalIOInterface(''InterfaceID'', ''Push Buttons'', ''InterfaceType'', ''IN'', ''PortName'', ''PushButtons'', ''PortWidth'', 2, ''FPGAPin'', {''G19'', ''F19''}, ''IOPadConstraint'', {''IOSTANDARD = LVCMOS25''})';
            hdlturnkey.plugin.validateExternalIOInterface(...
            exampleStr,varargin{:});

            obj.addInterface(...
            hdlturnkey.interface.InterfaceExternalIO(varargin{:}));
        end

    end

end


