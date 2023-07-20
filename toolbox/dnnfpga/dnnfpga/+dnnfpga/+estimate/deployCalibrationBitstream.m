function calData=deployCalibrationBitstream(bitstreamPath,ProcessorConfig)







    hRD=ProcessorConfig.getReferenceDesignObject;


    interfaceIDList=hRD.getInterfaceIDList();
    for ii=1:numel(interfaceIDList)
        hInterface=hRD.getInterface(interfaceIDList{ii});
        if hInterface.isAXI4Interface||hInterface.isAXI4LiteInterface
            baseAddrSlave=hInterface.BaseAddress;
            if iscell(baseAddrSlave)


                IPBaseAddress=baseAddrSlave{1};
            else
                IPBaseAddress=baseAddrSlave;
            end
            break;
        end
    end

    readBaseAddress=hRD.getDeepLearningMemorySpace;

    writeOffset='10000000';
    writeBaseAddress=dec2hex(readBaseAddress+hex2dec(writeOffset));
    readBaseAddress=dec2hex(readBaseAddress);


    if isequal(ProcessorConfig.SynthesisTool,'Xilinx Vivado')
        target='Xilinx';

        boardObject=ProcessorConfig.getBoardObject;

        filProgramFPGA(ProcessorConfig.SynthesisTool,bitstreamPath,boardObject.JTAGChainPosition);
    else
        target='altera';
        filProgramFPGA(ProcessorConfig.SynthesisTool,bitstreamPath);
    end

    hTarget=aximanager(target);

    ddrRDbase=readBaseAddress(1:5);
    ddrWRbase=writeBaseAddress(1:5);

    ipBase=IPBaseAddress(3:7);




    numBurstValues=7;


    numIterations=5;
    ReadLatencies=zeros(numIterations,numBurstValues);
    WriteLatencies=zeros(numIterations,numBurstValues);
    BurstLengths=zeros(1,numBurstValues);



    for j=1:numIterations
        for i=1:numBurstValues
            MatrixSize=2^(i+1);
            burstLength=MatrixSize^2+MatrixSize;

            input=uint32(randi([1,100],1,burstLength));
            dnnfpga.estimate.calibrateWriteDDR(hTarget,burstLength,ddrRDbase,ddrWRbase,ipBase,input);
            [ReadLatency,WriteLatency]=dnnfpga.estimate.calibrateReadDDR(hTarget,ipBase);
            ReadLatencies(j,i)=ReadLatency;
            WriteLatencies(j,i)=WriteLatency;
            BurstLengths(1,i)=burstLength;
        end
    end


    ReadLatencies=mean(ReadLatencies,1);
    WriteLatencies=mean(WriteLatencies,1);


    calData.BurstLengths=BurstLengths;
    calData.ReadLatencies=ReadLatencies;
    calData.WriteLatencies=WriteLatencies;

    save('calibrationData.mat','calData');

end
