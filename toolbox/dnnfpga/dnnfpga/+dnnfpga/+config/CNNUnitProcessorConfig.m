classdef CNNUnitProcessorConfig<dnnfpga.config.ProcessorConfigBase



    properties

    end

    methods
        function obj=CNNUnitProcessorConfig()



            obj=obj@dnnfpga.config.ProcessorConfigBase();

        end

        function validateProcessorConfig(obj)


        end

    end

    methods(Hidden)

        function bcc=applyProcessorConfigtoBCC(obj)

        end

        function hProcessor=createProcessorObject(obj)


            moduleID=obj.getModuleIDList{:};
            module=obj.getModule(moduleID);



            threadNumLimit=module.ThreadNumber;
            opDDRBitWidthLimit=module.DDRBitWidth;
            kernelDataType=module.KernelDataType;
            dataTransNum=module.DataTransferNumber;



            switch moduleID
            case 'input'
                bcc=dnnfpga.processorbase.processorUtils.getAlexnetBCCInputP(threadNumLimit,opDDRBitWidthLimit,kernelDataType,dataTransNum);
                hProcessor=dnnfpga.processorbase.inputProcessor(bcc);
            case 'output'
                bcc=dnnfpga.processorbase.processorUtils.getAlexnetBCCOutputP(threadNumLimit,opDDRBitWidthLimit,kernelDataType,dataTransNum);
                hProcessor=dnnfpga.processorbase.outputProcessor(bcc);
            otherwise
                hProcessor=[];
            end
        end
    end
end


