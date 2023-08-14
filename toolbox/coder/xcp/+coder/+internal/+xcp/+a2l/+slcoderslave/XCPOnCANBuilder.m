classdef XCPOnCANBuilder<handle






    properties(Constant,Access=private)

        VersionDefault=0x0100;
        CanIdBroadcastDefault=uint32.empty;
        CanIdMasterDefault=uint32.empty;
        CanIdSlaveDefault=uint32.empty;
        BaudRateDefault=uint32(10000000);
        SamplePointDefault=uint8.empty;
        SampleRateDefault=asam.mcd2mc.ifdata.xcp.CanSampleRateEnum.empty;
        BtlCyclesDefault=uint8.empty;
        SjwDefault=uint8.empty;
        SyncEdgeDefault=asam.mcd2mc.ifdata.xcp.CanSyncEdgeEnum.empty;
        MaxDlcRequiredDefault=false;
        DaqListCanIdDefault=asam.mcd2mc.ifdata.xcp.DaqListCanIdInfo.empty;


        CanIdBroadcastMacro='XCP_CAN_ID_BROADCAST';
        CanIdMasterMacro='XCP_CAN_ID_MASTER';
        CanIdSlaveMacro='XCP_CAN_ID_SLAVE';
        BaudRateMacro='XCP_CAN_BAUDRATE';
        SamplePointMacro='XCP_CAN_SAMPLE_POINT';
        SampleRateMacro='XCP_CAN_SAMPLE_RATE';
        SampleRateCondition={
        'SINGLE|((0[xX])?0*1)','SINGLE';
        'TRIPLE|((0[xX])?0*3)','TRIPLE'};

        BtlCyclesMacro='XCP_CAN_BTL_CYCLES';
        SjwMacro='XCP_CAN_SJW';
        SyncEdgeMacro='XCP_CAN_SYNC_EDGE';
        SyncEdgeCondition={
        'SINGLE|((0[xX])?0*1)','SINGLE';
        'DUAL|((0[xX])?0*2)','DUAL'};

        MaxDlcRequiredMacro='XCP_CAN_MAX_DLC_REQUIRED';

    end

    methods(Access=public)
        function obj=XCPOnCANBuilder()



        end

        function obj=build(obj,defineMap,xcpOnCAN)

            className=mfilename('class');
            validateattributes(defineMap,{'containers.Map'},{},className,'defineMap');
            validateattributes(xcpOnCAN,{'asam.mcd2mc.ifdata.xcp.XCPOnCANInfo'},{},className,'xcpOnCAN');

            xcpOnCAN.Version=obj.VersionDefault;

            if(defineMap.isKey(obj.MaxDlcRequiredMacro))
                xcpOnCAN.MaxDlcRequired=true;
            else
                xcpOnCAN.MaxDlcRequired=obj.MaxDlcRequiredDefault;
            end

            xcpOnCAN.DaqListCanId=obj.DaqListCanIdDefault;

            defineToA2LConverter=coder.internal.xcp.a2l.DefineToA2LConverter(defineMap);
            xcpOnCAN.CanIdBroadcast=uint32(defineToA2LConverter.getNumericValue(obj.CanIdBroadcastMacro,obj.CanIdBroadcastDefault));
            xcpOnCAN.CanIdMaster=uint32(defineToA2LConverter.getNumericValue(obj.CanIdMasterMacro,obj.CanIdMasterDefault));
            xcpOnCAN.CanIdSlave=uint32(defineToA2LConverter.getNumericValue(obj.CanIdSlaveMacro,obj.CanIdSlaveDefault));
            xcpOnCAN.BaudRate=uint32(defineToA2LConverter.getNumericValue(obj.BaudRateMacro,obj.BaudRateDefault));
            xcpOnCAN.SamplePoint=uint8(defineToA2LConverter.getNumericValue(obj.SamplePointMacro,obj.SamplePointDefault));
            xcpOnCAN.SampleRate=defineToA2LConverter.getEnumValue(obj.SampleRateMacro,obj.SampleRateCondition,obj.SampleRateDefault);
            xcpOnCAN.BtlCycles=uint8(defineToA2LConverter.getNumericValue(obj.BtlCyclesMacro,obj.BtlCyclesDefault));
            xcpOnCAN.Sjw=uint8(defineToA2LConverter.getNumericValue(obj.SjwMacro,obj.SjwDefault));
            xcpOnCAN.SyncEdge=defineToA2LConverter.getEnumValue(obj.SyncEdgeMacro,obj.SyncEdgeCondition,obj.SyncEdgeDefault);
        end
    end
end
