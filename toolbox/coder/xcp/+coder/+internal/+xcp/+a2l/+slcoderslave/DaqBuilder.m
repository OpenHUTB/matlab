classdef DaqBuilder<handle






    properties(Constant,Access=private)

        DaqConfigDefault='DYNAMIC';
        MaxDaqDefault=0xFFFF;
        MaxEventChannelDefault=0x80;
        MinDaqDefault=0x00;
        OptimisationTypeDefault='OPTIMISATION_TYPE_DEFAULT';
        AddressExtensionTypeDefault='ADDRESS_EXTENSION_FREE';
        IdentificationFieldDefault='IDENTIFICATION_FIELD_TYPE_ABSOLUTE';
        GranularityOdtEntrySizeDaqDefault='GRANULARITY_ODT_ENTRY_SIZE_DAQ_BYTE';
        MaxOdtEntrySizeDaqDefault=0xFF;
        OverLoadIndicationDefault='NO_OVERLOAD_INDICATION';
        PrescalerSupportedDefault=false;
        ResumeSupportedDefault=false;
        StimDefault=asam.mcd2mc.ifdata.xcp.StimInfo.empty;
        PidOffSupportedDefault=false;



        MaxDaqMacro='XCP_MAX_DAQ';
        MaxEventChannelMacro='XCP_MAX_EVENT_CHANNEL';
        MinDaqMacro='XCP_MIN_DAQ';

        IdentificationFieldMacro='XCP_ID_FIELD_TYPE';
        IdentificationFieldCondition={'XCP_ID_ABSOLUTE_ODT_NUMBER|((0[xX])?0*0)','IDENTIFICATION_FIELD_TYPE_ABSOLUTE';
        'XCP_ID_REL_ODT_ABS_DAQ_NUMBER_BYTE|((0[xX])?0*1)','IDENTIFICATION_FIELD_TYPE_RELATIVE_BYTE';
        'XCP_ID_REL_ODT_ABS_DAQ_NUMBER_WORD|((0[xX])?0*2)','IDENTIFICATION_FIELD_TYPE_RELATIVE_WORD';
        'XCP_ID_REL_ODT_ABS_DAQ_NUMBER_WORD_ALIGN|((0[xX])?0*3)','IDENTIFICATION_FIELD_TYPE_RELATIVE_WORD_ALIGNED'};

        GranularityOdtEntrySizeDaqMacro='XCP_ADDRESS_GRANULARITY';
        GranularityOdtEntrySizeDaqCondition={'XCP_ADDRESS_GRANULARITY_BYTE|((0[xX])?0*1)','GRANULARITY_ODT_ENTRY_SIZE_DAQ_BYTE';
        'XCP_ADDRESS_GRANULARITY_WORD|((0[xX])?0*2)','GRANULARITY_ODT_ENTRY_SIZE_DAQ_WORD';
        'XCP_ADDRESS_GRANULARITY_DWORD|((0[xX])?0*4)','GRANULARITY_ODT_ENTRY_SIZE_DAQ_DWORD'};

        MaxOdtEntrySizeDaqMacro='XCP_MAX_ODT_ENTRY_SIZE';
    end

    methods
        function obj=DaqBuilder()



        end

        function build(obj,defineMap,events,timeStampSupported,daq)


            className=mfilename('class');
            validateattributes(defineMap,{'containers.Map'},{},className,'defineMap');
            validateattributes(events,{'asam.mcd2mc.ifdata.xcp.EventInfo'},{},className,'events');
            validateattributes(timeStampSupported,{'asam.mcd2mc.ifdata.xcp.TimeStampSupportedInfo'},{},className,'timeStampSupported');

            defineToA2LConverter=coder.internal.xcp.a2l.DefineToA2LConverter(defineMap);



            daq.DaqConfig=obj.DaqConfigDefault;
            daq.MaxDaq=defineToA2LConverter.getNumericValue(obj.MaxDaqMacro,obj.MaxDaqDefault);
            daq.MaxEventChannel=defineToA2LConverter.getNumericValue(obj.MaxEventChannelMacro,obj.MaxEventChannelDefault);
            daq.MinDaq=defineToA2LConverter.getNumericValue(obj.MinDaqMacro,obj.MinDaqDefault);
            daq.OptimisationType=obj.OptimisationTypeDefault;
            daq.AddressExtensionType=obj.AddressExtensionTypeDefault;
            daq.IdentificationField=defineToA2LConverter.getEnumValue(obj.IdentificationFieldMacro,obj.IdentificationFieldCondition,obj.IdentificationFieldDefault);
            daq.GranularityOdtEntrySizeDaq=defineToA2LConverter.getEnumValue(obj.GranularityOdtEntrySizeDaqMacro,obj.GranularityOdtEntrySizeDaqCondition,obj.GranularityOdtEntrySizeDaqDefault);
            daq.MaxOdtEntrySizeDaq=defineToA2LConverter.getNumericValue(obj.MaxOdtEntrySizeDaqMacro,obj.MaxOdtEntrySizeDaqDefault);
            daq.OverLoadIndication=obj.OverLoadIndicationDefault;
            daq.PrescalerSupported=obj.PrescalerSupportedDefault;
            daq.ResumeSupported=obj.ResumeSupportedDefault;
            daq.Stim=obj.StimDefault;
            daq.TimeStampSupported=timeStampSupported;
            daq.PidOffSupported=obj.PidOffSupportedDefault;
            daq.Event=events;
        end
    end
end