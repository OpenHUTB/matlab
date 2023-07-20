classdef CNN4ProcessorConfig<dnnfpga.config.ProcessorConfigBase




    properties

    end


    methods
        function obj=CNN4ProcessorConfig()



            obj=obj@dnnfpga.config.ProcessorConfigBase();


            convModule=dnnfpga.config.Conv4ModuleConfig();
            obj.addModule(convModule);

            fcModule=dnnfpga.config.FC4ModuleConfig();
            obj.addModule(fcModule);

        end

        function validateProcessorConfig(obj)


            convModule=obj.getModule('conv');
            fcModule=obj.getModule('fc');


            moduleIDList=obj.getModuleIDList;
            for ii=1:length(moduleIDList)
                moduleID=moduleIDList{ii};
                hModule=obj.getModule(moduleID);
                hModule.validateModuleConfig;
            end








            if strcmpi(convModule.KernelDataType,'single')&&...
                strcmpi(fcModule.KernelDataType,'int8')
                error(message('dnnfpga:quantization:UnsupportedDataTypeCombination'));
            end

        end

    end

    methods(Hidden)
        function bcc=applyProcessorConfigtoBCC(obj)






            convModule=obj.getModule('conv');
            fcModule=obj.getModule('fc');






            convThreadNumber=sqrt(convModule.ConvThreadNumber);


            convInputMemorySize=convModule.InputMemorySize;
            convOutputMemorySize=convModule.OutputMemorySize;



            convFeatureSizeLimit=convModule.FeatureSizeLimit;


            convLRNThreadNumber=convModule.LRNThreadNumber;


            convKernelDataType=convModule.KernelDataType;


            syncInstructionNumber=convModule.SyncInstructionNumber;


            convRoundingMode=convModule.RoundingMode;


            fcThreadNumber=fcModule.FCThreadNumber;
            fcInputMemorySize=fcModule.InputMemorySize;
            fcOutputMemorySize=fcModule.OutputMemorySize;
            fcKernelDataType=fcModule.KernelDataType;

            fcRoundingMode=fcModule.RoundingMode;



            fcWeightDataType='single';
            fcWeightAXIDataBitwidth=fcModule.WeightAXIDataBitwidth;




            dataTransNum=convThreadNumber;
            bcc=dnnfpga.bcc.getBCCDefaultCNN4(convThreadNumber,fcThreadNumber,fcWeightDataType,fcWeightAXIDataBitwidth,convKernelDataType,fcKernelDataType,dataTransNum,convRoundingMode,fcRoundingMode);






            bcc.convp.conv.inputMemDepthLimit=[convInputMemorySize(3);convInputMemorySize(1);convInputMemorySize(2)];
            bcc.convp.conv.resultMemDepthLimit=[convOutputMemorySize(3);convOutputMemorySize(1);convOutputMemorySize(2)];



            bcc.convp.conv.featureSizeLimit=[convFeatureSizeLimit;convFeatureSizeLimit;1];


            bcc.convp.conv.lrnCompWindowSize=convLRNThreadNumber;


            syncInstructionBits=ceil(log2(syncInstructionNumber));
            bcc.convp.syncInstFormat.newPCMax=bcc.convp.syncInstFormat.newPCMin+syncInstructionBits;
            bcc.convp.syncInstFormat.funcMax=bcc.convp.syncInstFormat.funcMin+syncInstructionBits;







            bcc.fcp.inputMemDepthLimit=fcInputMemorySize;
            bcc.fcp.resultMemDepthLimit=fcOutputMemorySize;
            bcc.fcp.matrixSizeLimit=[fcInputMemorySize;fcOutputMemorySize];
            bcc.fcp.fcOpDataType=fcWeightDataType;


            if dnnfpga.tool.useNFP(obj)
                fpLib='NativeFloatingPoint';
                fpLibParams='minlatency';




                bcc.convp.conv=dnnfpga.processorbase.processorUtils.resolveIPLatencies(bcc.convp.conv,fpLib,fpLibParams,0,{});
                bcc.fcp=dnnfpga.processorbase.processorUtils.resolveIPLatencies(bcc.fcp,fpLib,fpLibParams,0,{});
            else


            end

        end

        function hProcessor=createProcessorObject(obj)








            bcc=obj.applyProcessorConfigtoBCC;


            hProcessor=dnnfpga.processorbase.cnn4Processor(bcc);

        end


    end




end


