classdef UserSpecifiedBaseAddr
    methods(Static)
        function checkNoCollisions(deployableNet,inputBaseOffset,outputBaseOffset)





            function pair=getInputDataPair()
                fpgaLayer=deployableNet.getSingletonFPGALayer;
                paramsIR=fpgaLayer.getDepolyableIR(true);
                size=paramsIR.inputs.getSizeInBytes();
                size=size*deployableNet.InputFrameNumberLimit;
                pair={inputBaseOffset,inputBaseOffset+size};
            end

            function pair=getOutputDataPair()
                fpgaLayer=deployableNet.getSingletonFPGALayer;
                paramsIR=fpgaLayer.getDepolyableIR(true);
                size=paramsIR.inputs.getSizeInBytes();
                size=size*deployableNet.InputFrameNumberLimit;
                pair={outputBaseOffset,outputBaseOffset+size};
            end

            function pair=getInternalDataPair()
                ddrOffsetTable=deployableNet.DDROffsetTable;
                startOffset=dnnfpga.format.getDDROffsetAddress(ddrOffsetTable,"SchedulerDataOffset");
                endOffset=dnnfpga.format.getDDROffsetAddress(ddrOffsetTable,"EndOffset");
                pair={startOffset,endOffset};
            end

            function collide=pairsCollide(pair0,pair1)
                collide=(pair0{1}>pair1{1}&&pair0{1}<pair1{2})||...
                (pair0{2}>pair1{1}&&pair0{2}<pair1{2})||...
                (pair1{1}>pair0{1}&&pair1{1}<pair0{2})||...
                (pair0{1}==pair1{1}&&pair0{2}==pair1{2});
            end

            inputPair=getInputDataPair();
            outputPair=getOutputDataPair();
            internalPair=getInternalDataPair();


            if pairsCollide(inputPair,outputPair)
                msg=message('dnnfpga:workflow:InvalidBaseAddressValues',...
                'input',strcat('0x',dec2hex(inputPair{1})),strcat('0x',dec2hex(inputPair{2})),...
                'output',...
                strcat('0x',dec2hex(outputPair{1})),strcat('0x',dec2hex(outputPair{2})));
                error(msg);
            end
            if pairsCollide(inputPair,internalPair)
                msg=message('dnnfpga:workflow:InvalidBaseAddressValues',...
                'input',strcat('0x',dec2hex(inputPair{1})),strcat('0x',dec2hex(inputPair{2})),...
                'DL processor internal',...
                strcat('0x',dec2hex(internalPair{1})),strcat('0x',dec2hex(internalPair{2})));
                error(msg);
            end
            if pairsCollide(outputPair,internalPair)
                msg=message('dnnfpga:workflow:InvalidBaseAddressValues',...
                'output',strcat('0x',dec2hex(outputPair{1})),strcat('0x',dec2hex(outputPair{2})),...
                'DL processor internal',...
                strcat('0x',dec2hex(internalPair{1})),strcat('0x',dec2hex(internalPair{2})));
                error(msg);
            end
        end
        function checkNonNegative(inputBaseAddr,outputBaseAddr)
            if inputBaseAddr<0
                msg=message('dnnfpga:workflow:NegativeBaseAddressValue',...
                'input',strcat('-0x',dec2hex(-inputBaseAddr)));
                error(msg);
            end
            if outputBaseAddr<0
                msg=message('dnnfpga:workflow:NegativeBaseAddressValue',...
                'output',strcat('-0x',dec2hex(-outputBaseAddr)));
                error(msg);
            end
        end
        function checkValidAddress(hPC,addr,label)
            bcc=hPC.applyProcessorConfigtoBCC;
            dataTransNum=bcc.dataTransNum;
            type=hPC.ProcessorDataType;
            if strcmp(type,'single')
                dataTransNumInBytes=dataTransNum*4;
            else
                dataTransNumInBytes=dataTransNum;
            end
            rounded=ceil(addr/double(dataTransNumInBytes))*dataTransNumInBytes;
            if rounded~=addr
                msg=message('dnnfpga:workflow:InvalidBaseAddressValue',...
                label,strcat('0x',dec2hex(addr)),int2str(uint32(dataTransNumInBytes)));
                error(msg);
            end
        end
    end
end
