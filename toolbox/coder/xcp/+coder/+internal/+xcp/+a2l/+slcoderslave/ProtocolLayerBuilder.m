classdef ProtocolLayerBuilder<handle






    properties(Constant,Access=private)
        VersionDefault=0x0100;
        T1Default=0x03E8;
        T2Default=0xC8;
        T3Default=0x00;
        T4Default=0x00;
        T5Default=0x00;
        T6Default=0x00;
        T7Default=0x00;
        MaxCtoDefault=0xFF;
        MaxDtoDefault=0xFFFC;
        ByteOrderDefault='BYTE_ORDER_MSB_LAST';

        CommunicationModeSupportedDefault=asam.mcd2mc.ifdata.xcp.CommunicationModeSupportedInfo.empty;



        MaxCtoMacro='XCP_MAX_CTO_SIZE';
        MaxDtoMacro='XCP_MAX_DTO_SIZE';

        ByteOrderMacro='XCP_BIG_ENDIAN';
        ByteOrderMacroBigEndianCondition={[],'BYTE_ORDER_MSB_FIRST'};

        AddressGranularityMacro='XCP_ADDRESS_GRANULARITY';
        AddressGranularityCondition={'XCP_ADDRESS_GRANULARITY_BYTE|(0[xX])?0*0','ADDRESS_GRANULARITY_BYTE';
        'XCP_ADDRESS_GRANULARITY_WORD|(0[xX])?0*1','ADDRESS_GRANULARITY_WORD';
        'XCP_ADDRESS_GRANULARITY_DWORD|(0[xX])?0*2','ADDRESS_GRANULARITY_DWORD'};

        DaqSupportMacro='XCP_DAQ_SUPPORT';
        DaqSupportDefault=false;
        DaqSupportCondition='';

        CalSupportMacro='XCP_CALIBRATION_SUPPORT';
        CalSupportDefault=false;
        CalSupportCondition='';

        SetMtaSupportMacro='XCP_SET_MTA_SUPPORT';
        SetMtaSupportDefault=false;
        SetMtaSupportCondition='';

        DaqSupportCmds=[asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.ALLOC_ODT_ENTRY,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.ALLOC_ODT,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.ALLOC_DAQ,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.FREE_DAQ,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.GET_DAQ_RESOLUTION_INFO,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.GET_DAQ_PROCESSOR_INFO,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.START_STOP_SYNCH,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.START_STOP_DAQ_LIST,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SET_DAQ_LIST_MODE,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.WRITE_DAQ,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SET_DAQ_PTR];

        CalSupportCmds=asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SHORT_DOWNLOAD;

        SetMtaSupportCmds=[asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SET_MTA,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.UPLOAD,...
        asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.DOWNLOAD];

        OptionalCmdsAlwaysSupported=asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SHORT_UPLOAD;
    end

    properties(SetAccess=private,GetAccess=public)
        HasDaqSupport=false;
    end

    methods(Access=public)
        function obj=ProtocolLayerBuilder()



        end

        function build(obj,defineMap,typeInfo,protocolLayer)

            className=mfilename('class');
            validateattributes(defineMap,{'containers.Map'},{},className,'defineMap');
            validateattributes(typeInfo,{'struct'},{},className,'typeInfo');
            validateattributes(protocolLayer,{'asam.mcd2mc.ifdata.xcp.ProtocolLayerInfo'},{},className,'protocolLayer');

            defineToA2LConverter=coder.internal.xcp.a2l.DefineToA2LConverter(defineMap);

            protocolLayer.Version=obj.VersionDefault;
            protocolLayer.T1=obj.T1Default;
            protocolLayer.T2=obj.T2Default;
            protocolLayer.T3=obj.T3Default;
            protocolLayer.T4=obj.T4Default;
            protocolLayer.T5=obj.T5Default;
            protocolLayer.T6=obj.T6Default;
            protocolLayer.T7=obj.T7Default;


            protocolLayer.MaxCto=defineToA2LConverter.getNumericValue(obj.MaxCtoMacro,obj.MaxCtoDefault);


            protocolLayer.MaxDto=defineToA2LConverter.getNumericValue(obj.MaxDtoMacro,obj.MaxDtoDefault);


            protocolLayer.ByteOrder=defineToA2LConverter.getEnumValue(obj.ByteOrderMacro,...
            obj.ByteOrderMacroBigEndianCondition,...
            obj.ByteOrderDefault);



            if typeInfo.native8
                addressGranularityDefault='ADDRESS_GRANULARITY_BYTE';
            elseif typeInfo.native16
                addressGranularityDefault='ADDRESS_GRANULARITY_WORD';
            elseif typeInfo.native32
                addressGranularityDefault='ADDRESS_GRANULARITY_DWORD';
            else


                assert(false,'Target needs to support 8-bit, 16-bit or 32-bit types natively');
            end



            protocolLayer.AddressGranularity=defineToA2LConverter.getEnumValue(obj.AddressGranularityMacro,...
            obj.AddressGranularityCondition,...
            addressGranularityDefault);


            optionalCmds=[];
            obj.HasDaqSupport=defineToA2LConverter.getBoolCondition(obj.DaqSupportMacro,obj.DaqSupportCondition,obj.DaqSupportDefault);
            if obj.HasDaqSupport
                optionalCmds=[optionalCmds,obj.DaqSupportCmds];
            end

            hasCalSupport=defineToA2LConverter.getBoolCondition(obj.CalSupportMacro,obj.CalSupportCondition,obj.CalSupportDefault);
            if hasCalSupport
                optionalCmds=[optionalCmds,obj.CalSupportCmds];
            end

            hasSetMtaSupport=defineToA2LConverter.getBoolCondition(obj.SetMtaSupportMacro,obj.SetMtaSupportCondition,obj.SetMtaSupportDefault);
            if hasSetMtaSupport
                optionalCmds=[optionalCmds,obj.SetMtaSupportCmds];
            end



            protocolLayer.OptionalCmds=sort([optionalCmds,obj.OptionalCmdsAlwaysSupported]);
        end
    end
end
