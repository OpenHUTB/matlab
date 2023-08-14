function bcc=getBCCDefaultFC(threadNumLimit,fcOpDataType,opDDRBitWidthLimit,kernelDataType,RoundingMode,MemoryMinDepth)







    if(nargin<4)
        kernelDataType='single';
    end
    if(nargin<5)
        RoundingMode='Round';
    end
    if(nargin<6)
        MemoryMinDepth=1024;
    end
    bcc.kernelDataType=kernelDataType;
    bcc.RoundingMode=RoundingMode;
    bcc.MemoryMinDepth=MemoryMinDepth;

    bcc.layerModeNumWLimit=8;
    bcc.matrixSizeLimit=[9217;4096];
    bcc.resultMemDepthLimit=4096;
    bcc.inputMemDepthLimit=9216;
    bcc.resultNumWLimit=128;

    bcc.fcOpDataType=fcOpDataType;
    bcc.layerNumWLimit=32;
    bcc.debugIDNumWLimit=2^16;
    bcc.debugBankNumWLimit=2^16;
    bcc.debugCounterWLimit=32;
    bcc.debugDMADepthLimit=2^32;
    bcc.debugDMAWidthLimit=128;

    bcc.MADLatency=4;
    bcc.ProdLatency=3;
    bcc.SumLatency=6;
    bcc.CmpLatency=1;

    bcc.Fixdt_0_16_0_To_SingleLatency=4;
    bcc.MemReadLatency=1;
    bcc.DataMemReadLatency=2;
    bcc.DebugMemReadLatency=5;
    bcc.DebugMemRegularReadLatency=2;
    bcc.ControlLogicInputFeatureAddrIdx=1;
    bcc.ControlLogicOutputFeatureAddrIdx=3;

    bcc.coefFifoSizeLimit=512;
    bcc.opDDRBitWidthLimit=opDDRBitWidthLimit;
    if(opDDRBitWidthLimit<=128)
        bcc.opDUTBitWidthLimit=opDDRBitWidthLimit;
    else
        bcc.opDUTBitWidthLimit=128;
    end
    if(strcmpi(bcc.kernelDataType,'uint16'))
        opBitWidthLimit=16;
    elseif(strcmpi(bcc.kernelDataType,'int8'))
        opBitWidthLimit=8;
    else
        opBitWidthLimit=32;
    end

    bcc.threadNumLimit=threadNumLimit;


    bcc.halfProgLCFIFODepth=24*3;

    assert((threadNumLimit>=(bcc.opDDRBitWidthLimit/opBitWidthLimit)),'ThreadNum should be greater than or equal to %d',(bcc.opDDRBitWidthLimit/opBitWidthLimit));
    bcc.supportedProfileEvents={'Processor_Start','Processor_Done','Layer_Start','Layer_Done','WeightBurst_Start','WeightBurst_Done'};

    bcc.lcParam=cell(9,1);

    bcc.lcParam{1}.name='memDirection';
    bcc.lcParam{1}.dataType='boolean';
    bcc.lcParam{1}.vectorType=1;

    bcc.lcParam{2}.name='reLUMode';
    bcc.lcParam{2}.dataType='fixdt(0,3,0)';
    bcc.lcParam{2}.vectorType=1;

    bcc.lcParam{3}.name='iterCounterSize';
    bcc.lcParam{3}.dataType='fixdt(0,iterCounterWLimit,0)';
    bcc.lcParam{3}.vectorType=3;

    bcc.lcParam{4}.name='iterCounterSizeMinusOne';
    bcc.lcParam{4}.dataType='fixdt(0,iterCounterWLimit,0)';
    bcc.lcParam{4}.vectorType=3;

    bcc.lcParam{5}.name='RemapWeightDiffFraction';
    bcc.lcParam{5}.dataType='single';
    bcc.lcParam{5}.vectorType=1;

    bcc.lcParam{6}.name='RemapMinweightMultiplyConstant';
    bcc.lcParam{6}.dataType='single';
    bcc.lcParam{6}.vectorType=1;

    bcc.lcParam{7}.name='layerMode';
    bcc.lcParam{7}.dataType='fixdt(0,layerModeNumWLimit,0)';
    bcc.lcParam{7}.vectorType=1;

    bcc.lcParam{8}.name='memSelect';
    bcc.lcParam{8}.dataType='boolean';
    bcc.lcParam{8}.vectorType=1;

    bcc.lcParam{9}.name='int32ToInt8Exp';
    bcc.lcParam{9}.dataType='kernelDataType';
    bcc.lcParam{9}.vectorType=1;

    bcc.lcParam{10}.name='reLUValue';
    bcc.lcParam{10}.dataType='dnnfpgaDataTypeChange( kernelDataType, 0)';
    bcc.lcParam{10}.vectorType=1;

    bcc.lcParam{end+1}.name='fcBias';
    bcc.lcParam{end}.dataType='dnnfpgaDataTypeChange( kernelDataType, 0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='reLUScaleExp';
    bcc.lcParam{end}.dataType='fixdt(1,8,0)';
    bcc.lcParam{end}.vectorType=1;

    lcParam=cell2mat(bcc.lcParam);
    bcc.layerConfigNumWLimit=sum([lcParam.vectorType]);

    bcc.offset=0;
    bcc.supportedDebugMem={'input','result','lc','weightdebug','logdisablingmask','logtimestamps','logtimestampscount','logdata','logdatacount','prefechingCounter','prefetchingCounterStopper','bitstreamChecksum','networkChecksum'};


    bcc.DebugParams{1}.debugblock='input';
    bcc.DebugParams{1}.debugTag='FC_DEBUGOUTTAG_0';
    bcc.DebugParams{1}.debugId=bcc.offset+0;

    bcc.DebugParams{2}.debugblock='result';
    bcc.DebugParams{2}.debugTag='FC_DEBUGOUTTAG_1';
    bcc.DebugParams{2}.debugId=bcc.offset+1;

    bcc.DebugParams{3}.debugblock='lc';
    bcc.DebugParams{3}.debugTag='FC_DEBUGOUTTAG_2';
    bcc.DebugParams{3}.debugId=bcc.offset+2;

    bcc.DebugParams{4}.debugblock='logdisablingmask';
    bcc.DebugParams{4}.debugTag='FC_DEBUGOUTTAG_4';
    bcc.DebugParams{4}.debugId=bcc.offset+4;

    bcc.DebugParams{5}.debugblock='logtimestamps';
    bcc.DebugParams{5}.debugTag='FC_DEBUGOUTTAG_5';
    bcc.DebugParams{5}.debugId=bcc.offset+5;

    bcc.DebugParams{6}.debugblock='logtimestampscount';
    bcc.DebugParams{6}.debugTag='FC_DEBUGOUTTAG_6';
    bcc.DebugParams{6}.debugId=bcc.offset+6;

    bcc.DebugParams{7}.debugblock='logdata';
    bcc.DebugParams{7}.debugTag='FC_DEBUGOUTTAG_7';
    bcc.DebugParams{7}.debugId=bcc.offset+7;

    bcc.DebugParams{8}.debugblock='logdatacount';
    bcc.DebugParams{8}.debugTag='FC_DEBUGOUTTAG_8';
    bcc.DebugParams{8}.debugId=bcc.offset+8;

    bcc.DebugParams{9}.debugblock='bitstreamChecksum';
    bcc.DebugParams{9}.debugTag='FC_DEBUGOUTTAG_11';
    bcc.DebugParams{9}.debugId=bcc.offset+11;

    bcc.DebugParams{10}.debugblock='networkChecksum';
    bcc.DebugParams{10}.debugTag='FC_DEBUGOUTTAG_12';
    bcc.DebugParams{10}.debugId=bcc.offset+12;

end





