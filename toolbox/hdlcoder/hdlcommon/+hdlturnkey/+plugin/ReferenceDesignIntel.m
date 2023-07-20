



classdef(Abstract)ReferenceDesignIntel<hdlturnkey.plugin.ReferenceDesign


    properties
    end

    properties(Hidden=true)


        CustomQsysPrjFile='';


        CustomUpdateQsysTcl='';


        CustomUpdateProjTcl='';



        CustomQuartusFiles={};


        CustomCreateBinTcl='';


        BootFromSD=false;


        IPInsertionMethod='';
        ReplacedIPInstance='';


        FilterStringCell={};

    end

    properties(Hidden=true,Constant)

        QsysExampleStr='hRD.addCustomQsysDesign(''CustomQsysPrjFile'', ''system_soc.qsys'')';
        AXI4SlaveExampleStr='hRD.addAXI4SlaveInterface(''InterfaceConnection'', ''AXI_Manager_0.axm_m0'', ''BaseAddress'', ''0x0000_0000'', ''IDWidth'', 12)';
        ExpectedEmbeddedCoderSupportPackage=hdlcoder.EmbeddedCoderSupportPackage.AlteraSoC;
    end

    methods

        function obj=ReferenceDesignIntel()

            obj=obj@hdlturnkey.plugin.ReferenceDesign();
        end

        function addCustomQsysDesign(obj,varargin)


            p=inputParser;
            p.addParameter('CustomQsysPrjFile','');

            p.parse(varargin{:});
            inputArgs=p.Results;



            hdlturnkey.plugin.validateSingleMethod(...
            obj.CustomQsysPrjFile,'addCustomQsysDesign()');


            hdlturnkey.plugin.validateRequiredParameter(...
            inputArgs.CustomQsysPrjFile,'CustomQsysPrjFile',obj.QsysExampleStr);


            obj.CustomQsysPrjFile=inputArgs.CustomQsysPrjFile;
        end

        function addInternalIOInterface(obj,varargin)



















            exampleStr='hRD.addInternalIOInterface(''InterfaceID'', ''InternalPort'', ''InterfaceType'', ''OUT'', ''PortName'', ''RefInternalIO'', ''PortWidth'', 8, ''InterfaceConnection'', ''internal_ip_0.Inport1''})';
            hdlturnkey.plugin.validateInternalIOInterface(...
            exampleStr,varargin{:});

            obj.addInterface(...
            hdlturnkey.interface.InterfaceInternalIOAlteraSoC(varargin{:}));
        end

        function addAXI4StreamInterface(obj,varargin)


            obj.addInterface(hdlturnkey.interface.AXI4Stream(varargin{:}));
        end

        function addAXI4MasterInterface(obj,varargin)


            obj.addInterface(hdlturnkey.interface.AXI4Master(varargin{:}));
        end

    end

    methods(Access=protected)

        function validateReferenceDesignAdditional(obj)



            hdlturnkey.plugin.validateRequiredMethod(...
            obj.CustomQsysPrjFile,'addCustomQsysDesign()',obj.QsysExampleStr);
        end

        function validateAXI4SlaveInterfaceType(obj,interfaceType,interfaceID)
            validateAXI4SlaveInterfaceType@hdlturnkey.plugin.ReferenceDesign(obj,interfaceType,interfaceID);


            isAXI4Lite=length(interfaceType)==1&&strcmp(interfaceType{1},'AXI4-Lite');
            if isAXI4Lite
                error(message('hdlcommon:plugin:AXI4LiteQuartus'));
            end
        end

        function addAXI4LiteInterface(obj,varargin)


        end

    end

    methods(Hidden=true)

        function addCustomEDKDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomEDKDesign()','Xilinx ISE','addCustomQsysDesign()'));
        end

        function addCustomVivadoDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomVivadoDesign()','Xilinx Vivado','addCustomQsysDesign()'));
        end

        function addCustomLiberoDesign(obj,varargin)

            error(message('hdlcommon:plugin:InvalidRefMethod',...
            'addCustomLiberoDesign()','Microchip Libero SoC','addCustomQsysDesign()'));
        end

        function addExternalIOInterface(obj,varargin)



            exampleStr='hRD.addExternalIOInterface(''InterfaceID'', ''Push Buttons'', ''InterfaceType'', ''IN'', ''PortName'', ''PushButtons'', ''PortWidth'', 2, ''FPGAPin'', {''G19'', ''F19''}, ''IOPadConstraint'', {''IO_STANDARD "2.5V"''})';
            hdlturnkey.plugin.validateExternalIOInterface(...
            exampleStr,varargin{:});

            obj.addInterface(...
            hdlturnkey.interface.InterfaceExternalIO(varargin{:}));
        end

    end

end



