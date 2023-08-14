classdef fc4Processor<dnnfpga.processorbase.fcProcessor


    methods(Access=public,Hidden=true)
        function obj=fc4Processor(bcc)
            obj@dnnfpga.processorbase.fcProcessor(bcc);
        end
    end

    methods


        function nc=resolveNC(obj,params)

            nc=resolveNC@dnnfpga.processorbase.fcProcessor(obj,params);
            cc=obj.getCC();


            first_layer_param=params{1};
            last_layer_param=params{end};


            fc_ip_ddr_len=obj.resolveInputSizeLayer(first_layer_param);
            fc_ip_ddr_len=ceil(fc_ip_ddr_len/cc.threadNumLimit)*cc.threadNumLimit;
            nc.fc_ip_ddr_len=fc_ip_ddr_len;


            nc.result_count=obj.resolveOutputSizeLayer(last_layer_param);


















            nc.fc_op_ddr_len=ceil(nc.result_count/cc.threadNumLimit)*cc.threadNumLimit;


            nc.fc_weightSize=nc.WeightSize/(cc.opDDRRatio*cc.fixedBitSlice);


            if(mod(nc.layerNumMinusOne,2)==0)
                nc.fc_op_dir=1;
            else
                nc.fc_op_dir=0;
            end


            nc.hasFC=true;

        end



        function output=backend(obj,params,convDataTransNum,convLastLayerDDROffset,fcOutputResultOffset)

            layerData=backend@dnnfpga.processorbase.abstractProcessor(obj,params);
            layerDataModule=struct('moduleSeqLC',[]);
            layerNum=length(params);
            iLength=numel(layerData.seqLC)/layerNum;
            layerLC=reshape(layerData.seqLC,[iLength,numel(layerData.seqLC)/iLength]);


            for i=1:length(params)
                param=params{i};
                layerDataModule(i)=obj.getModuleSeqLCPerLayer(param,layerData.NC,convDataTransNum,convLastLayerDDROffset,fcOutputResultOffset);
                layerDataModule(i).moduleSeqLC=[single(0),layerLC(:,i)',layerDataModule(i).moduleSeqLC];
            end

            output.seqOp=layerData.seqOp;
            output.seqLC=layerData.seqLC;
            output.moduleSeqLC=[layerDataModule.moduleSeqLC];
            output.NC=layerData.NC;
        end

        function layerDataModule=getModuleSeqLCPerLayer(obj,param,networkConfig,convDataTransNum,convLastLayerDDROffset,fcOutputResultOffset)
            layerConfig=dnnfpga.processorbase.processorUtils.resolveModuleLCPerLayerFC(param,obj.getCC,networkConfig,convDataTransNum,convLastLayerDDROffset,fcOutputResultOffset);
            layerDataModule.moduleSeqLC=obj.moduleSeqLayerConfig(layerConfig,'single');
        end

        function moduleSeqLC=moduleSeqLayerConfig(obj,lcs,storedType)
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





