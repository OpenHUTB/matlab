classdef XCPOnSxIBuilder<handle






    properties(Constant,Access=private)

        VersionDefault=0x0100;
        AsynchFullDuplexModeDefault=true;
        AsynchFullDuplexModeParityDefault='PARITY_NONE';
        AsynchFullDuplexModeStopBitsDefault='ONE_STOP_BIT';
        SynchFullDuplexModeByteDefault=false;
        SynchFullDuplexModeWordDefault=false;
        SynchFullDuplexModeDWordDefault=false;
        SynchMasterSlaveModeByteDefault=false;
        SynchMasterSlaveModeWordDefault=false;
        SynchMasterSlaveModeDWordDefault=false;
        HeaderLengthDefault='HEADER_LEN_CTR_WORD';
        ChecksumDefault='CHECKSUM_WORD';


        HeaderLengthMacro='XCP_SERIAL_HEADER_FORMAT';
        HeaderLengthCondition={
        'LEN_BYTE|((0[xX])?0*0)','HEADER_LEN_BYTE';
        'LEN_BYTE_CTR_BYTE|((0[xX])?0*1)','HEADER_LEN_CTR_BYTE';
        'LEN_BYTE_EMPTY_BYTE|((0[xX])?0*2)','HEADER_LEN_FILL_BYTE';
        'LEN_WORD|((0[xX])?0*3)','HEADER_LEN_WORD';
        'LEN_WORD_CTR_WORD|((0[xX])?0*4)','HEADER_LEN_CTR_WORD';
        'LEN_WORD_EMPTY_WORD|((0[xX])?0*5)','HEADER_LEN_FILL_WORD'};

        ChecksumMacro='XCP_SERIAL_TAIL_FORMAT'
        ChecksumCondition={...
        'NO_CHECKSUM|((0[xX])?0*0)','NO_CHECKSUM'
        'CHECKSUM_BYTE|((0[xX])?0*1)','CHECKSUM_BYTE'
        'CHECKSUM_WORD|((0[xX])?0*2)','CHECKSUM_WORD'};
    end

    methods(Access=public)
        function obj=XCPOnSxIBuilder()



        end

        function obj=build(obj,defineMap,baudRate,xcpOnSxi)

            className=mfilename('class');
            validateattributes(defineMap,{'containers.Map'},{},className,'defineMap');
            validateattributes(baudRate,{'numeric'},{'nonnegative','scalar'},className,'baudRate');
            validateattributes(xcpOnSxi,{'asam.mcd2mc.ifdata.xcp.XCPOnSxIInfo'},{},className,'xcpOnSxi');


            xcpOnSxi.Version=obj.VersionDefault;
            xcpOnSxi.BaudRate=baudRate;

            xcpOnSxi.AsynchFullDuplexMode=obj.AsynchFullDuplexModeDefault;
            xcpOnSxi.AsynchFullDuplexModeParity=obj.AsynchFullDuplexModeParityDefault;
            xcpOnSxi.AsynchFullDuplexModeStopBits=obj.AsynchFullDuplexModeStopBitsDefault;
            xcpOnSxi.SynchFullDuplexModeByte=obj.SynchFullDuplexModeByteDefault;
            xcpOnSxi.SynchFullDuplexModeWord=obj.SynchFullDuplexModeWordDefault;
            xcpOnSxi.SynchFullDuplexModeDWord=obj.SynchFullDuplexModeDWordDefault;
            xcpOnSxi.SynchMasterSlaveModeByte=obj.SynchMasterSlaveModeByteDefault;
            xcpOnSxi.SynchMasterSlaveModeWord=obj.SynchMasterSlaveModeWordDefault;
            xcpOnSxi.SynchMasterSlaveModeDWord=obj.SynchMasterSlaveModeDWordDefault;

            defineToA2LConverter=coder.internal.xcp.a2l.DefineToA2LConverter(defineMap);
            xcpOnSxi.HeaderLength=defineToA2LConverter.getEnumValue(obj.HeaderLengthMacro,obj.HeaderLengthCondition,obj.HeaderLengthDefault);
            xcpOnSxi.Checksum=defineToA2LConverter.getEnumValue(obj.ChecksumMacro,obj.ChecksumCondition,obj.ChecksumDefault);
        end
    end
end
