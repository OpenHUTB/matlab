classdef IFDataXCPBuilder<handle







    methods(Access=public)
        function obj=IFDataXCPBuilder()



        end

        function build(~,periodicEventList,transportLayerInfo,ifdataxcp)

            className=mfilename('class');
            validateattributes(periodicEventList,{'coder.internal.xcp.a2l.slrealtime.PeriodicEventList'},{},className,'periodicEventList');
            validateattributes(transportLayerInfo,{'coder.internal.xcp.a2l.TransportLayerInfo'},{},className,'transportLayerInfo');
            validateattributes(ifdataxcp,{'asam.mcd2mc.ifdata.xcp.IFDataXCPInfo'},{},className,'ifdataxcp');


            ifdataxcp.ProtocolLayer=asam.mcd2mc.create('ProtocolLayerInfo');
            ifdataxcp.ProtocolLayer.Version=0x100;
            ifdataxcp.ProtocolLayer.T1=0x3e8;
            ifdataxcp.ProtocolLayer.T2=0xc8;
            ifdataxcp.ProtocolLayer.MaxCto=0xFC;
            ifdataxcp.ProtocolLayer.MaxDto=0x0578;
            ifdataxcp.ProtocolLayer.ByteOrder='BYTE_ORDER_MSB_LAST';
            ifdataxcp.ProtocolLayer.AddressGranularity='ADDRESS_GRANULARITY_BYTE';
            ifdataxcp.ProtocolLayer.OptionalCmds=[...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.ALLOC_ODT_ENTRY,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.ALLOC_ODT,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.ALLOC_DAQ,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.FREE_DAQ,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.GET_DAQ_CLOCK,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.GET_DAQ_RESOLUTION_INFO,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.GET_DAQ_PROCESSOR_INFO,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.START_STOP_SYNCH,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.START_STOP_DAQ_LIST,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SET_DAQ_LIST_MODE,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.WRITE_DAQ,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SET_DAQ_PTR,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.GET_CAL_PAGE,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SET_CAL_PAGE,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.COPY_CAL_PAGE,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SHORT_DOWNLOAD,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.DOWNLOAD_MAX,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.DOWNLOAD,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SHORT_UPLOAD,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.UPLOAD,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SET_MTA,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.GET_SEGMENT_INFO,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.GET_PAGE_INFO,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.SET_SEGMENT_MODE,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.GET_SEGMENT_MODE,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.GET_PAG_PROCESSOR_INFO,...
            asam.mcd2mc.ifdata.xcp.OptionalCmdEnum.MODIFY_BITS];


            timeStampSupported=asam.mcd2mc.create('TimeStampSupportedInfo');
            timeStampSupported.TimeStampTicks=0x01;
            timeStampSupported.TimeStampSize='SIZE_DWORD';
            timeStampSupported.TimeStampResolution='UNIT_1US';
            timeStampSupported.TimeStampFixed=true;






            suppressWarning=true;
            eventBuilder=coder.internal.xcp.a2l.EventBuilder(suppressWarning);
            eventObjs=asam.mcd2mc.ifdata.xcp.EventInfo.empty;
            for kEvt=1:periodicEventList.NumEvents

                eventObjs(end+1)=asam.mcd2mc.create('EventInfo');%#ok<AGROW>

                eventBuilder.build(...
                periodicEventList.TIDs(kEvt),...
                periodicEventList.Rates(kEvt),...
                eventObjs(end));
            end


            ifdataxcp.Daq=asam.mcd2mc.create('DaqInfo');
            ifdataxcp.Daq.DaqConfig='DYNAMIC';
            ifdataxcp.Daq.MaxDaq=0;
            ifdataxcp.Daq.MaxEventChannel=0x80;
            ifdataxcp.Daq.MinDaq=0;
            ifdataxcp.Daq.OptimisationType='OPTIMISATION_TYPE_DEFAULT';
            ifdataxcp.Daq.AddressExtensionType='ADDRESS_EXTENSION_FREE';
            ifdataxcp.Daq.IdentificationField='IDENTIFICATION_FIELD_TYPE_RELATIVE_WORD_ALIGNED';
            ifdataxcp.Daq.GranularityOdtEntrySizeDaq='GRANULARITY_ODT_ENTRY_SIZE_DAQ_BYTE';
            ifdataxcp.Daq.MaxOdtEntrySizeDaq=0xFF;
            ifdataxcp.Daq.OverLoadIndication='OVERLOAD_INDICATION_PID';
            ifdataxcp.Daq.PrescalerSupported=true;
            ifdataxcp.Daq.TimeStampSupported=timeStampSupported;
            ifdataxcp.Daq.Event=eventObjs;

            ifdataxcp.Daq.Stim=asam.mcd2mc.create('StimInfo');
            ifdataxcp.Daq.Stim.MaxOdtEntrySizeStim=255;
            ifdataxcp.Daq.Stim.BitStimSupported=0;
            ifdataxcp.Daq.Stim.GranularityOdtEntrySizeStim=...
            asam.mcd2mc.ifdata.xcp.GranularityOdtEntrySizeStimEnum(1);


            assert(transportLayerInfo.isUdp());

            xcpOnUdpIp=asam.mcd2mc.create('XCPOnUDPIPInfo');
            xcpOnUdpIpBuilder=coder.internal.xcp.a2l.XCPOnEthernetBuilder;
            xcpOnUdpIpBuilder.build(transportLayerInfo.Address,transportLayerInfo.Port,xcpOnUdpIp);
            ifdataxcp.XCPOnPhysical=xcpOnUdpIp;
        end
    end

end
