classdef BitstreamBuildInfo

































    properties(GetAccess=public,SetAccess=protected)
        ProcessorConfig=[];
        VendorName='';
        BoardName='';
        ReferenceDesignName='';
        Frequency=0;
    end


    properties(GetAccess=public,SetAccess=protected,Hidden=true)

        Processor=[];




        Resources struct=[];


        MATLABVersion='';
        ProcessorVersion='0';


        SupportedTool={};
        SupportedToolVersion={};


        SupportedProgrammingMethods hdlcoder.ProgrammingMethod
        CallbackCustomProgrammingMethod=[];


        DeviceTreeName='';
        SystemInitFolderName='';
        GenerateSplitBitstream=false;


        hasJTAGInterface=false;
        hasPCIeInterface=false;
        hasEthernetInterface=false;


        DLProcessorBaseAddr=0;
        DLProcessorAddrRange=0;

        DLMemoryBaseAddr=0;
        DLMemoryAddrRange=0;


        JTAGChainPosition=1;
        IRLengthBefore=[];
        IRLengthAfter=[];


        DLProcessorDevNameTx='';
        DLProcessorDevNameRx='';

        DLMemoryDevNameTx='';
        DLMemoryDevNameRx='';
    end

    methods(Access=public,Hidden=true)
        function obj=BitstreamBuildInfo(processor,MV,frequency,boardPlugin,referenceDesignPlugin,hPC,resources,processorVersion)






            if nargin<8
                processorVersion='0';
            end
            if nargin<7
                resources=[];
            end
            if nargin<6
                hPC=[];
            end



            obj.Processor=processor;
            obj.ProcessorConfig=hPC;
            obj.MATLABVersion=MV;
            obj.ProcessorVersion=processorVersion;
            obj.Frequency=frequency;
            obj.Resources=resources;

            if nargin>3&&~isempty(boardPlugin)
                obj=obj.setPropertiesFromBoard(boardPlugin);
            end

            if nargin>4&&~isempty(referenceDesignPlugin)
                obj=obj.setPropertiesFromReferenceDesign(referenceDesignPlugin);
            end

        end
    end

    methods(Hidden=true)
        function val=getPropertyInternal(obj,prop)










            val=obj.(prop);
        end

        function obj=setPropertyInternal(obj,prop,val)











            obj.(prop)=val;
        end
    end


    methods(Access=protected)
        function obj=setPropertiesFromReferenceDesign(obj,hRD)

            obj.ReferenceDesignName=hRD.ReferenceDesignName;


            obj.SupportedToolVersion=hRD.SupportedToolVersion;


            obj.SupportedProgrammingMethods=hRD.SupportedProgrammingMethods;
            obj.CallbackCustomProgrammingMethod=hRD.CallbackCustomProgrammingMethod;


            obj.DeviceTreeName=hRD.getDeviceTree;
            obj.SystemInitFolderName=hRD.getSystemInit;
            obj.GenerateSplitBitstream=hRD.GenerateSplitBitstream;


            obj.hasJTAGInterface=hRD.hasDeepLearningInterfaceOfType("JTAG");
            obj.hasPCIeInterface=hRD.hasDeepLearningInterfaceOfType("PCIe");
            obj.hasEthernetInterface=hRD.hasDeepLearningInterfaceOfType("Ethernet");


            interfaceIDList=hRD.getInterfaceIDList();
            for ii=1:numel(interfaceIDList)
                hInterface=hRD.getInterface(interfaceIDList{ii});
                if hInterface.isAXI4Interface||hInterface.isAXI4LiteInterface
                    baseAddrSlave=hInterface.BaseAddress;
                    if iscell(baseAddrSlave)


                        baseAddrSlave=baseAddrSlave{1};
                    end


                    baseAddrSlave=hex2dec(baseAddrSlave);
                    addrRangeSlave=hex2dec('0x10000');
                    break;
                end
            end

            obj.DLProcessorBaseAddr=baseAddrSlave;
            obj.DLProcessorAddrRange=addrRangeSlave;


            [obj.DLMemoryBaseAddr,obj.DLMemoryAddrRange]=hRD.getDeepLearningMemorySpace;


            if obj.hasEthernetInterface
                hEthernetInterface=hRD.getDeepLearningInterfaceOfType("Ethernet");
                [obj.DLProcessorDevNameTx,obj.DLProcessorDevNameRx]=hEthernetInterface.getDLProcessorDeviceNames;
                [obj.DLMemoryDevNameTx,obj.DLMemoryDevNameRx]=hEthernetInterface.getMemoryDeviceNames;
            end
        end

        function obj=setPropertiesFromBoard(obj,hBoard)

            obj.VendorName=hBoard.FPGAVendor;
            if strcmpi(obj.VendorName,'Altera')
                obj.VendorName='Intel';
            end


            obj.SupportedTool=hBoard.SupportedTool;


            obj.BoardName=hBoard.BoardName;



            obj.JTAGChainPosition=hBoard.JTAGChainPosition;



            obj.IRLengthBefore=hBoard.IRLengthBefore;
            obj.IRLengthAfter=hBoard.IRLengthAfter;
        end
    end
end


