classdef(Abstract)ConvModuleConfigBase<dnnfpga.config.ModuleConfigBase





    properties




ConvThreadNumber


InputMemorySize
OutputMemorySize
MemoryMinimumDepth


FeatureSizeLimit
    end

    properties(Hidden)



LRNThreadNumber

    end


    properties(Constant,Hidden)

        ConvThreadNumberDefault=16;
        InputMemorySizeDefault=[227,227,3];
        OutputMemorySizeDefault=[227,227,3];















        FeatureSizeLimitDefault=2048;
        FeatureSizeLimitRange=[10,16384];






        LRNThreadNumberChoices={1,3,9};
        LRNThreadNumberDefault=1;




        MemorySizeMinValue=[10,10,1];
        MemoryMinimumDepthDefault=[32,32,1];
    end

    methods
        function obj=ConvModuleConfigBase(varargin)



            propList={...
            {'ModuleID','conv'},...
            };


            p=downstream.tool.parseInputProperties(propList,varargin{:});
            inputArgs=p.Results;


            moduleID=inputArgs.ModuleID;
            obj=obj@dnnfpga.config.ModuleConfigBase(moduleID);


            obj.ConvThreadNumber=obj.ConvThreadNumberDefault;
            obj.InputMemorySize=obj.InputMemorySizeDefault;
            obj.OutputMemorySize=obj.OutputMemorySizeDefault;
            obj.FeatureSizeLimit=obj.FeatureSizeLimitDefault;
            obj.MemoryMinimumDepth=obj.MemoryMinimumDepthDefault;

            obj.LRNThreadNumber=obj.LRNThreadNumberDefault;



            obj.Properties('TopLevelProperties')=cat(2,{...
            'ConvThreadNumber',...
            'InputMemorySize',...
            'OutputMemorySize',...
            'FeatureSizeLimit',...
            'LRNThreadNumber',...
            },obj.Properties('TopLevelProperties'));


            obj.HiddenProperties('LRNThreadNumber')=true;
            obj.HiddenProperties('MemoryMinimumDepth')=true;


        end

    end


    methods
        function set.ConvThreadNumber(obj,val)

            convThreadNumberChoices=obj.getConvThreadNumberChoices;
            dnnfpga.config.validatePositiveIntegerPropertyValue(val,'ConvThreadNumber',...
            convThreadNumberChoices,obj.ConvThreadNumberDefault)
            obj.ConvThreadNumber=val;



            obj.updateWhenConvThreadNumberChange;
        end

        function set.InputMemorySize(obj,val)
            dnnfpga.config.validatePositiveIntegerVectorProperty(val,'InputMemorySize',...
            obj.InputMemorySizeDefault);
            dnnfpga.config.validate3DVectorProperty(val,'InputMemorySize',...
            obj.InputMemorySizeDefault);
            dnnfpga.config.validatePositiveIntegerPropertyMinValue(val,'InputMemorySize',...
            obj.MemorySizeMinValue,obj.InputMemorySizeDefault);
            obj.InputMemorySize=val;
        end

        function set.OutputMemorySize(obj,val)
            dnnfpga.config.validatePositiveIntegerVectorProperty(val,'OutputMemorySize',...
            obj.OutputMemorySizeDefault);
            dnnfpga.config.validate3DVectorProperty(val,'OutputMemorySize',...
            obj.OutputMemorySizeDefault);
            dnnfpga.config.validatePositiveIntegerPropertyMinValue(val,'OutputMemorySize',...
            obj.MemorySizeMinValue,obj.OutputMemorySizeDefault);
            obj.OutputMemorySize=val;
        end
        function set.MemoryMinimumDepth(obj,val)
            dnnfpga.config.validatePositiveIntegerVectorProperty(val,'MemoryMinimumDepth',...
            obj.MemoryMinimumDepthDefault);
            dnnfpga.config.validate3DVectorProperty(val,'MemoryMinimumDepth',...
            obj.MemoryMinimumDepthDefault);
            obj.MemoryMinimumDepth=val;
        end

        function set.FeatureSizeLimit(obj,val)
            dnnfpga.config.validatePositiveIntegerPropertyRange(val,'FeatureSizeLimit',...
            obj.FeatureSizeLimitRange,obj.FeatureSizeLimitDefault);
            obj.FeatureSizeLimit=val;
        end

        function set.LRNThreadNumber(obj,val)
            dnnfpga.config.validatePositiveIntegerPropertyValue(val,'LRNThreadNumber',...
            obj.LRNThreadNumberChoices,obj.LRNThreadNumberDefault);
            obj.LRNThreadNumber=val;
        end

    end


    methods(Abstract,Hidden,Access=public)



        updateWhenConvThreadNumberChange(obj)

    end


    methods(Abstract,Access=protected)


        getConvThreadNumberChoices(obj)

    end

end


