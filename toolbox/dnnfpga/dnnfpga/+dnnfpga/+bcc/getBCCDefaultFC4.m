function bcc=getBCCDefaultFC4(threadNumLimit,opDataType,opDDRBitWidthLimit,kernelDataType,RoundingMode,MemoryMinDepth)







    if(nargin<3)
        opDDRBitWidthLimit=128;
    end
    if(nargin<4)
        kernelDataType='single';
    end
    if(nargin<5)
        RoundingMode='Round';
    end
    if(nargin<6)
        MemoryMinDepth=1024;
    end

    bcc=dnnfpga.bcc.getBCCDefaultFC(threadNumLimit,opDataType,opDDRBitWidthLimit,kernelDataType,RoundingMode,MemoryMinDepth);




    bcc.lcParam{1}.name='ip_ddr_addr';
    bcc.lcParam{1}.dataType='uint32';
    bcc.lcParam{1}.vectorType=1;

    bcc.lcParam{2}.name='ip_ddr_len';
    bcc.lcParam{2}.dataType='uint32';
    bcc.lcParam{2}.vectorType=1;

    bcc.lcParam{3}.name='ip_dir';
    bcc.lcParam{3}.dataType='boolean';
    bcc.lcParam{3}.vectorType=1;

    bcc.lcParam{4}.name='op_ddr_addr';
    bcc.lcParam{4}.dataType='uint32';
    bcc.lcParam{4}.vectorType=1;

    bcc.lcParam{5}.name='op_ddr_offset';
    bcc.lcParam{5}.dataType='uint32';
    bcc.lcParam{5}.vectorType=1;

    bcc.lcParam{6}.name='op_ddr_len';
    bcc.lcParam{6}.dataType='uint32';
    bcc.lcParam{6}.vectorType=1;

    bcc.lcParam{7}.name='op_dir';
    bcc.lcParam{7}.dataType='boolean';
    bcc.lcParam{7}.vectorType=1;

    bcc.lcParam{8}.name='weightSize';
    bcc.lcParam{8}.dataType='uint32';
    bcc.lcParam{8}.vectorType=1;


    bcc.lcParam{9}.name='fcOutputExp';
    bcc.lcParam{9}.dataType='fixdt(1,8,0)';
    bcc.lcParam{9}.vectorType=1;


    bcc.lcParam{10}.name='fcInputExp';
    bcc.lcParam{10}.dataType='fixdt(1,8,0)';
    bcc.lcParam{10}.vectorType=1;

    bcc.lcParam{11}.name='gapMultiplier';
    bcc.lcParam{11}.dataType='dnnfpgaDataTypeChange( kernelDataType, 0)';
    bcc.lcParam{11}.vectorType=1;

    bcc.lcParam{12}.name='layerNum';
    bcc.lcParam{12}.dataType='uint8';
    bcc.lcParam{12}.vectorType=1;


    bcc.lcParam{end+1}.name='denominatorAddressSizeMinusOne';
    bcc.lcParam{end}.dataType='fixdt(0,iterCounterWLimit,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='numberOfPaddedZeros';
    bcc.lcParam{end}.dataType='uint8';
    bcc.lcParam{end}.vectorType=1;



    bcc.lcParam{end+1}.name='memDirection';
    bcc.lcParam{end}.dataType='boolean';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='reLUMode';
    bcc.lcParam{end}.dataType='fixdt(0,3,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='iterCounterSize';
    bcc.lcParam{end}.dataType='fixdt(0,iterCounterWLimit,0)';
    bcc.lcParam{end}.vectorType=3;

    bcc.lcParam{end+1}.name='iterCounterSizeMinusOne';
    bcc.lcParam{end}.dataType='fixdt(0,iterCounterWLimit,0)';
    bcc.lcParam{end}.vectorType=3;

    bcc.lcParam{end+1}.name='RemapWeightDiffFraction';
    bcc.lcParam{end}.dataType='single';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='RemapMinweightMultiplyConstant';
    bcc.lcParam{end}.dataType='single';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='layerMode';
    bcc.lcParam{end}.dataType='fixdt(0,layerModeNumWLimit,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='memSelect';
    bcc.lcParam{end}.dataType='boolean';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='int32ToInt8Exp';
    bcc.lcParam{end}.dataType='kernelDataType';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='reLUValue';
    bcc.lcParam{end}.dataType='dnnfpgaDataTypeChange( kernelDataType, 0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='fcBias';
    bcc.lcParam{end}.dataType='dnnfpgaDataTypeChange( kernelDataType, 0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='reLUScaleExp';
    bcc.lcParam{end}.dataType='fixdt(1,8,0)';
    bcc.lcParam{end}.vectorType=1;

    bcc.lcParam{end+1}.name='weightAddrOffset';
    bcc.lcParam{end}.dataType='uint32';
    bcc.lcParam{end}.vectorType=1;

    lcParam=cell2mat(bcc.lcParam);
    bcc.layerConfigNumWLimit=sum([lcParam.vectorType]);
end


