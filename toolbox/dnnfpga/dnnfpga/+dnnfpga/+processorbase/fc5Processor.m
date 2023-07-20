classdef fc5Processor<dnnfpga.processorbase.fc4Processor


    methods(Access=public,Hidden=true)
        function obj=fc5Processor(bcc)
            obj@dnnfpga.processorbase.fc4Processor(bcc);
        end
    end

    methods
        function nc=resolveNC(obj,params)

            nc=resolveNC@dnnfpga.processorbase.fc4Processor(obj,params);
        end

        function output=backend(obj,params,dataTransNum,weightBaseAddrOffset)


            layerData=backend@dnnfpga.processorbase.abstractProcessor(obj,params);
            layerDataModule=struct('moduleSeqLC',[]);
            layerNum=length(params);
            iLength=numel(layerData.seqLC)/layerNum;
            layerLC=reshape(layerData.seqLC,[iLength,numel(layerData.seqLC)/iLength]);
            fccc=obj.getCC();
            fcthreadNum=fccc.threadNumLimit;
            if(strcmp(fccc.kernelDataType,'int8'))

                AddrIncBuffOffset=1;
            else
                AddrIncBuffOffset=4;
            end

            for i=1:length(params)


                layerDataModule(i)=obj.getModuleSeqLC(params{i},layerData.NC,dataTransNum,fcthreadNum);
                layerDataModule(i).moduleSeqLC=[typecast(uint32(weightBaseAddrOffset),'single'),...
                layerLC(:,i)',layerDataModule(i).moduleSeqLC];
            end
            output.seqOp=layerData.seqOp;
            output.seqLC=layerData.seqLC;
            output.moduleSeqLC=[layerDataModule.moduleSeqLC];
            output.NC=layerData.NC;





            output.weightBaseAddrOffset=weightBaseAddrOffset+layerData.NC.WeightSize*AddrIncBuffOffset;
        end

        function layerDataModule=getModuleSeqLC(obj,params,networkConfig,dataTransNum,fcthreadNum)
            layerConfig=dnnfpga.processorbase.processorUtils.resolveModuleLCPerFCModule(params,networkConfig,dataTransNum,fcthreadNum);
            layerDataModule.moduleSeqLC=obj.moduleSeqLayerConfig(layerConfig,'single');
        end

        function moduleSeqLC=moduleSeqLayerConfig(~,lcs,storedType)
            fieldNames={
            'ip_ddr_addr',...
'ip_ddr_len'...
            ,'ip_dir',...
            'op_ddr_addr',...
            'op_ddr_offset',...
            'op_ddr_len',...
            'op_dir',...
            'weightSize',...
            'fcOutputExp',...
            'fcInputExp',...
            'gapMultiplier',...
'layerNum'...
            ,'denominatorAddressSizeMinusOne'...
            ,'numberOfPaddedZeros'...
            };
            moduleSeqLC=dnnfpga.assembler.seqLayerConfigPrivate(lcs,storedType,fieldNames);
        end

    end


end





