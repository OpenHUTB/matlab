function bcc=getBCCDefaultConv2(threadNumLimit,opDDRBitWidthLimit,kernelDataType,RoundingMode,MemoryMinDepth)







    if(nargin<2)
        opDDRBitWidthLimit=128;
    end

    if(nargin<3)
        kernelDataType='single';
    end

    if(nargin<4)
        RoundingMode='Round';
    end
    if(nargin<5)
        MemoryMinDepth=[32,32,1];
    end

    bcc.kernelDataType=kernelDataType;
    bcc.RoundingMode=RoundingMode;
    bcc.MemoryMinDepth=MemoryMinDepth;

    bcc.imageNumWLimit=300;


    bcc.layerModeNumWLimit=8;


    bcc.imgWLimit=227;

    bcc.featureSizeLimit=[1024;1024;1];







    bcc.origOpWLimit=36;
    bcc.unpoolKernelMinSize=[2;2];


    bcc.resultMemDepthLimit=[96;55;55];
    bcc.inputMemDepthLimit=[3;227;227];

    bcc.opW=3;
    bcc.superConvolutionFirstDimensionLimit=4;



    bcc.strideModeWLimit=16;
    bcc.paddingModeWLimit=8;
    bcc.dilationModeWLimit=8;
    bcc.layerNumWLimit=32;
    bcc.debugIDNumWLimit=2^16;
    bcc.debugBankNumWLimit=2^16;
    bcc.debugCounterWLimit=32;
    bcc.debugDMADepthLimit=2^32;
    bcc.debugDMAWidthLimit=128;
    bcc.lrnLocalSizeLimit=9;
    bcc.Fixdt_0_16_0_To_SingleLatency=4;






    bcc.ProdLatency=3;
    bcc.SumLatency=3;
    bcc.MADLatency=4;
    bcc.CmpLatency=1;
    bcc.ExpLatency=25;
    bcc.LogLatency=20;
    bcc.DivideLatency=17;
    bcc.MemReadLatency=1;
    bcc.DataMemReadLatency=6;
    bcc.DebugMemReadLatency=5;
    bcc.DebugMemRegularReadLatency=2;
    bcc.Addr3DTo1DLatency=5;
    bcc.ControlLogicInputFeatureAddrIdx=4;
    bcc.ControlLogicOutputFeatureAddrIdx=5;
    bcc.ControlLogicTileXAddrIdx=2;
    bcc.ControlLogicTileYAddrIdx=3;
    bcc.threadNumLimit=threadNumLimit;
    bcc.CONV_TRANS_CTRL_LATENCY=5;
    bcc.opBitWidthLimit=32;

    bcc.halfProgLCFIFODepth=126*3;
    bcc.opDDRBitWidthLimit=opDDRBitWidthLimit;
    bcc.smallPoolLatency=32;
    if(opDDRBitWidthLimit<=128)
        bcc.opDUTBitWidthLimit=opDDRBitWidthLimit;
    else
        bcc.opDUTBitWidthLimit=128;
    end
    bcc.supportedProfileEvents={'Processor_Start','Processor_Done','Layer_Start','Layer_Done','WeightBurst_Start','WeightBurst_Done'};

    bcc.lcParam{1}.name='memDirection';
    bcc.lcParam{1}.dataType='boolean';
    bcc.lcParam{1}.vectorType=1;

    bcc.lcParam{2}.name='convMode';
    bcc.lcParam{2}.dataType='fixdt(0,layerModeNumWLimit,0)';
    bcc.lcParam{2}.vectorType=1;

    bcc.lcParam{3}.name='strideMode';
    bcc.lcParam{3}.dataType='fixdt(0,strideModeAddrW,0)';
    bcc.lcParam{3}.vectorType=1;

    bcc.lcParam{4}.name='reLUMode';
    bcc.lcParam{4}.dataType='fixdt(0,3,0)';
    bcc.lcParam{4}.vectorType=1;

    bcc.lcParam{5}.name='paddingMode';
    bcc.lcParam{5}.dataType='fixdt(0,paddingModeAddrW,0)';
    bcc.lcParam{5}.vectorType=1;

    bcc.lcParam{6}.name='halfInputFeatureNum';
    bcc.lcParam{6}.dataType='fixdt(0,ceil(log2(max(featureSizeLimit)))-1,0)';
    bcc.lcParam{6}.vectorType=1;

    bcc.lcParam{7}.name='halfOutputFeatureNum';
    bcc.lcParam{7}.dataType='fixdt(0,ceil(log2(max(featureSizeLimit)))-1,0)';
    bcc.lcParam{7}.vectorType=1;

    bcc.lcParam{8}.name='convTileSize';
    bcc.lcParam{8}.dataType='fixdt(0,ceil(log2(max(superConvolutionSizeLimit)))+1,0)';
    bcc.lcParam{8}.vectorType=6;

    bcc.lcParam{9}.name='convTileThreadExpansionSize';
    bcc.lcParam{9}.dataType='fixdt(0,ceil(log2(max(superConvolutionSizeLimit)))+1,0)';
    bcc.lcParam{9}.vectorType=3;

    bcc.lcParam{10}.name='convImgSize';
    bcc.lcParam{10}.dataType='fixdt(0,ceil(log2(max(imgSizeLimit)))+1,0)';
    bcc.lcParam{10}.vectorType=3;

    bcc.lcParam{11}.name='convOpSize';
    bcc.lcParam{11}.dataType='fixdt(0,ceil(log2(max(origOpSizeLimit)))+1,0)';
    bcc.lcParam{11}.vectorType=3;

    bcc.lcParam{12}.name='leftMemSize';
    bcc.lcParam{12}.dataType='fixdt(0,dataMemAddrW+1,0)';
    bcc.lcParam{12}.vectorType=3;

    bcc.lcParam{13}.name='rightMemSize';
    bcc.lcParam{13}.dataType='fixdt(0,dataMemAddrW+1,0)';
    bcc.lcParam{13}.vectorType=3;

    bcc.lcParam{14}.name='stride';
    bcc.lcParam{14}.dataType='fixdt(0,strideModeAddrW,0)';
    bcc.lcParam{14}.vectorType=1;

    bcc.lcParam{15}.name='padding';
    bcc.lcParam{15}.dataType='fixdt(0,paddingModeAddrW,0)';
    bcc.lcParam{15}.vectorType=4;

    bcc.lcParam{16}.name='dilation';
    bcc.lcParam{16}.dataType='fixdt(0,dilationModeAddrW,0)';
    bcc.lcParam{16}.vectorType=1;

    bcc.lcParam{17}.name='resultSize';
    bcc.lcParam{17}.dataType='fixdt(0,imgAddrW,0)';
    bcc.lcParam{17}.vectorType=2;

    bcc.lcParam{18}.name='resultSizeDivByOpW';
    bcc.lcParam{18}.dataType='fixdt(0,zAddrW,0)';
    bcc.lcParam{18}.vectorType=2;

    bcc.lcParam{19}.name='resultSizeDivByOpWSquared';
    bcc.lcParam{19}.dataType='fixdt(0,zAddrW*2,0)';
    bcc.lcParam{19}.vectorType=1;

    bcc.lcParam{20}.name='imgSize';
    bcc.lcParam{20}.dataType='fixdt(0,imgAddrW,0)';
    bcc.lcParam{20}.vectorType=2;

    bcc.lcParam{21}.name='imgSizeDivByOpW';
    bcc.lcParam{21}.dataType='fixdt(0,zAddrW,0)';
    bcc.lcParam{21}.vectorType=2;

    bcc.lcParam{22}.name='imgSizeDivByOpWSquared';
    bcc.lcParam{22}.dataType='fixdt(0,zAddrW*2,0)';
    bcc.lcParam{22}.vectorType=1;

    bcc.lcParam{23}.name='xy0';
    bcc.lcParam{23}.dataType='fixdt(1,zAddrW+1,0)';
    bcc.lcParam{23}.vectorType=18;

    bcc.lcParam{24}.name='rxy0';
    bcc.lcParam{24}.dataType='fixdt(1,imgAddrW+1,0)';
    bcc.lcParam{24}.vectorType=18;

    bcc.lcParam{25}.name='wAddr0';
    bcc.lcParam{25}.dataType='fixdt(0,dataMemAddrW+1,0)';
    bcc.lcParam{25}.vectorType=1;

    bcc.lcParam{26}.name='dw';
    bcc.lcParam{26}.dataType='fixdt(0,ceil(log2(dwLimit)),0)';
    bcc.lcParam{26}.vectorType=1;

    bcc.lcParam{27}.name='dr';
    bcc.lcParam{27}.dataType='fixdt(0,ceil(log2(drLimit)),0)';
    bcc.lcParam{27}.vectorType=1;

    bcc.lcParam{28}.name='dz';
    bcc.lcParam{28}.dataType='fixdt(0,ceil(log2(dzLimit)),0)';
    bcc.lcParam{28}.vectorType=1;

    bcc.lcParam{29}.name='rzLimitOriginal';
    bcc.lcParam{29}.dataType='fixdt(1,imgAddrW+1,0)';
    bcc.lcParam{29}.vectorType=2;

    bcc.lcParam{end+1}.name='lrnLocalSize';
    bcc.lcParam{end}.dataType='fixdt(0,8,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='lrnAlpha';
    bcc.lcParam{end}.dataType='single';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='lrnBeta';
    bcc.lcParam{end}.dataType='single';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='lrnK';
    bcc.lcParam{end}.dataType='single';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='lrnFeaturePadding';
    bcc.lcParam{end}.dataType='fixdt(0,11,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='convOutputFeature';
    bcc.lcParam{end}.dataType='fixdt(0,11,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='lrnPadddingSize';
    bcc.lcParam{end}.dataType='fixdt(0,11,0)';
    bcc.lcParam{end}.vectorType=3;

    bcc.lcParam{end+1}.name='inputMemZAdapterActive';
    bcc.lcParam{end}.dataType='fixdt(0,1,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='activeFIFOEn';
    bcc.lcParam{end}.dataType='fixdt(0,1,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='activeFIFOMemSel';
    bcc.lcParam{end}.dataType='fixdt(0,1,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='accumulateRightMem';
    bcc.lcParam{end}.dataType='fixdt(0,1,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='finalWriteSize';
    bcc.lcParam{end}.dataType='fixdt(0,imgAddrW,0)';
    bcc.lcParam{end}.vectorType=2;

    bcc.lcParam{end+1}.name='convOpSizePlusPaddingSizeMinusOne';
    bcc.lcParam{end}.dataType='fixdt(1,7,0)';
    bcc.lcParam{end}.vectorType=3;

    bcc.lcParam{end+1}.name='convImgSizeMinusOne';
    bcc.lcParam{end}.dataType='fixdt(0,ceil(log2(max(imgSizeLimit)))+1,0)';
    bcc.lcParam{end}.vectorType=3;

    bcc.lcParam{end+1}.name='convImgSizeMinusOpSizePlusTwoPaddingSize';
    bcc.lcParam{end}.dataType='fixdt(0,10,0)';
    bcc.lcParam{end}.vectorType=3;

    bcc.lcParam{end+1}.name='convTileSizeMinusOne';
    bcc.lcParam{end}.dataType='fixdt(0,ceil(log2(max(superConvolutionSizeLimit)))+1,0)';
    bcc.lcParam{end}.vectorType=5;

    bcc.lcParam{end+1}.name='convTileSizeMinusTwo';
    bcc.lcParam{end}.dataType='fixdt(0,ceil(log2(max(superConvolutionSizeLimit)))+1,0)';
    bcc.lcParam{end}.vectorType=5;




    bcc.lcParam{end+1}.name='convReLUValue';
    bcc.lcParam{end}.dataType='single';
    bcc.lcParam{end}.vectorType=1;


    bcc.lcParam{end+1}.name='avgpoolMultiplier';
    bcc.lcParam{end}.dataType='kernelDataType';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='firstWritePos';
    bcc.lcParam{end}.dataType='fixdt(0,imgAddrW,0)';
    bcc.lcParam{end}.vectorType=4;


    bcc.lcParam{end+1}.name='int32ToInt8Exp';
    bcc.lcParam{end}.dataType='kernelDataType';
    bcc.lcParam{end}.vectorType=1;


    bcc.lcParam{end+1}.name='int8ToSingleExp';
    bcc.lcParam{end}.dataType='fixdt(1,8,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='singleToInt8Exp';
    bcc.lcParam{end}.dataType='fixdt(1,8,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='reLUScaleExp';
    bcc.lcParam{end}.dataType='fixdt(1,8,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='smallPoolLayerEn';
    bcc.lcParam{end}.dataType='fixdt(1,8,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='weightBaseAddrOffset';
    bcc.lcParam{end}.dataType='fixdt(0,32,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='nextTileOffset';
    bcc.lcParam{end}.dataType='fixdt(0,32,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='isMaxpoolIndexLeg';
    bcc.lcParam{end}.dataType='fixdt(0,1,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='fullFeatureSize';
    bcc.lcParam{end}.dataType='fixdt(0,32,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='fullColumnsSize';
    bcc.lcParam{end}.dataType='fixdt(0,32,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='IndexActsSelectorOffsetInit';
    bcc.lcParam{end}.dataType='fixdt(0, convIndexActsSelectorOffsetAddrW, 0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='IndexActsDimensionalOffsetsInit';
    bcc.lcParam{end}.dataType='fixdt(0, convIndexActsSelectorOffsetAddrW, 0)';
    bcc.lcParam{end}.vectorType=3;

    lcParam=cell2mat(bcc.lcParam);
    bcc.layerConfigNumWLimit=sum([lcParam.vectorType]);

    bcc.offset=0;
    bcc.supportedDebugMem={'input','result','lc','weightdebug','logdisablingmask','logtimestamps','logtimestampscount','logdata','logdatacount','prefechingCounter','prefetchingCounterStopper','bitstreamChecksum','networkChecksum'};



    bcc.DebugParams{1}.debugblock='input';
    bcc.DebugParams{1}.debugTag='CONV2_DEBUGOUTTAG_0';
    bcc.DebugParams{1}.debugId=0;

    bcc.DebugParams{2}.debugblock='result';
    bcc.DebugParams{2}.debugTag='CONV2_DEBUGOUTTAG_1';
    bcc.DebugParams{2}.debugId=1;

    bcc.DebugParams{3}.debugblock='lc';
    bcc.DebugParams{3}.debugTag='CONV2_DEBUGOUTTAG_2';
    bcc.DebugParams{3}.debugId=2;

    bcc.DebugParams{4}.debugblock='weightdebug';
    bcc.DebugParams{4}.debugTag='CONV2_DEBUGOUTTAG_3';
    bcc.DebugParams{4}.debugId=3;

    bcc.DebugParams{5}.debugblock='logdisablingmask';
    bcc.DebugParams{5}.debugTag='CONV2_DEBUGOUTTAG_4';
    bcc.DebugParams{5}.debugId=4;

    bcc.DebugParams{6}.debugblock='logtimestamps';
    bcc.DebugParams{6}.debugTag='CONV2_DEBUGOUTTAG_5';
    bcc.DebugParams{6}.debugId=5;

    bcc.DebugParams{7}.debugblock='logtimestampscount';
    bcc.DebugParams{7}.debugTag='CONV2_DEBUGOUTTAG_6';
    bcc.DebugParams{7}.debugId=6;

    bcc.DebugParams{8}.debugblock='logdata';
    bcc.DebugParams{8}.debugTag='CONV2_DEBUGOUTTAG_7';
    bcc.DebugParams{8}.debugId=7;

    bcc.DebugParams{9}.debugblock='logdatacount';
    bcc.DebugParams{9}.debugTag='CONV2_DEBUGOUTTAG_8';
    bcc.DebugParams{9}.debugId=8;

    bcc.DebugParams{10}.debugblock='prefechingCounter';
    bcc.DebugParams{10}.debugTag='CONV2_DEBUGOUTTAG_9';
    bcc.DebugParams{10}.debugId=9;

    bcc.lrnCompWindowSize=1;

end






