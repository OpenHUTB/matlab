classdef CNN2ProcessorConfig<dnnfpga.config.ProcessorConfigBase




    properties

    end


    methods
        function obj=CNN2ProcessorConfig()



            obj=obj@dnnfpga.config.ProcessorConfigBase();


            convModule=dnnfpga.config.Conv2ModuleConfig();
            obj.addModule(convModule);

            fcModule=dnnfpga.config.FCModuleConfig();
            obj.addModule(fcModule);


        end

        function validateProcessorConfig(obj)%#ok<MANU>



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


            fcThreadNumber=fcModule.FCThreadNumber;
            fcInputMemorySize=fcModule.InputMemorySize;
            fcOutputMemorySize=fcModule.OutputMemorySize;
            fcWeightDataType=fcModule.WeightDataType;
            fcWeightAXIDataBitwidth=fcModule.WeightAXIDataBitwidth;




            bcc=dnnfpga.bcc.getBCCDefaultCNN2(convThreadNumber,fcThreadNumber,fcWeightDataType,fcWeightAXIDataBitwidth);






            bcc.conv.inputMemDepthLimit=[convInputMemorySize(3);convInputMemorySize(1);convInputMemorySize(2)];
            bcc.conv.resultMemDepthLimit=[convOutputMemorySize(3);convOutputMemorySize(1);convOutputMemorySize(2)];



            bcc.conv.featureSizeLimit=[convFeatureSizeLimit;convFeatureSizeLimit;1];


            bcc.conv.lrnCompWindowSize=convLRNThreadNumber;







            bcc.fc.inputMemDepthLimit=fcInputMemorySize;
            bcc.fc.resultMemDepthLimit=fcOutputMemorySize;
            bcc.fc.fcOpDataType=fcWeightDataType;



            useNFP=strcmpi(obj.SynthesisTool,'Xilinx Vivado');
            if useNFP
                fpLib='NativeFloatingPoint';
                fpLibParams='minlatency';




                bcc.conv=dnnfpga.processorbase.processorUtils.resolveIPLatencies(bcc.conv,fpLib,fpLibParams,0,{});
                bcc.fc=dnnfpga.processorbase.processorUtils.resolveIPLatencies(bcc.fc,fpLib,fpLibParams,0,{});
            else


            end

        end

        function hProcessor=createProcessorObject(obj)








            bcc=obj.applyProcessorConfigtoBCC;


            hProcessor=dnnfpga.processorbase.cnn2Processor(bcc);

        end


    end




end


