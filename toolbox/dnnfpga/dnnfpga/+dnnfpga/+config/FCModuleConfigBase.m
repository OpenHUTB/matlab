classdef(Abstract)FCModuleConfigBase<dnnfpga.config.ModuleConfigBase





    properties




FCThreadNumber


InputMemorySize
OutputMemorySize
MemoryMinimumDepth
    end


    properties(Constant,Hidden)

        FCThreadNumberDefault=4;
        InputMemorySizeDefault=25088;
        OutputMemorySizeDefault=4096;







        MemorySizeMinValue=128;
        MemoryMinimumDepthDefault=1024;
    end

    methods
        function obj=FCModuleConfigBase(varargin)



            propList={...
            {'ModuleID','fc'},...
            };


            p=downstream.tool.parseInputProperties(propList,varargin{:});
            inputArgs=p.Results;


            moduleID=inputArgs.ModuleID;
            obj=obj@dnnfpga.config.ModuleConfigBase(moduleID);


            obj.FCThreadNumber=obj.FCThreadNumberDefault;
            obj.InputMemorySize=obj.InputMemorySizeDefault;
            obj.OutputMemorySize=obj.OutputMemorySizeDefault;
            obj.MemoryMinimumDepth=obj.MemoryMinimumDepthDefault;


            obj.Properties('TopLevelProperties')=cat(2,{...
            'FCThreadNumber',...
            'InputMemorySize',...
            'OutputMemorySize',...
            },obj.Properties('TopLevelProperties'));


            obj.HiddenProperties('MemoryMinimumDepth')=true;
        end

    end


    methods
        function set.FCThreadNumber(obj,val)

            fcThreadNumberChoices=obj.getFCThreadNumberChoices;
            dnnfpga.config.validatePositiveIntegerPropertyValue(val,'FCThreadNumber',...
            fcThreadNumberChoices,obj.FCThreadNumberDefault)
            obj.FCThreadNumber=val;



            obj.updateWhenFCThreadNumberChange;
        end

        function set.InputMemorySize(obj,val)
            dnnfpga.config.validatePositiveIntegerProperty(val,'InputMemorySize',...
            obj.InputMemorySizeDefault);
            dnnfpga.config.validatePositiveIntegerPropertyMinValue(val,'InputMemorySize',...
            obj.MemorySizeMinValue,obj.InputMemorySizeDefault);
            obj.InputMemorySize=val;
        end

        function set.OutputMemorySize(obj,val)
            dnnfpga.config.validatePositiveIntegerProperty(val,'OutputMemorySize',...
            obj.OutputMemorySizeDefault);
            dnnfpga.config.validatePositiveIntegerPropertyMinValue(val,'OutputMemorySize',...
            obj.MemorySizeMinValue,obj.OutputMemorySizeDefault);
            obj.OutputMemorySize=val;
        end

        function set.MemoryMinimumDepth(obj,val)
            dnnfpga.config.validatePositiveIntegerProperty(val,'MemoryMinimumDepth',...
            obj.MemoryMinimumDepthDefault);
            obj.MemoryMinimumDepth=val;
        end

    end


    methods(Abstract,Hidden,Access=public)



        updateWhenFCThreadNumberChange(obj)

    end


    methods(Abstract,Access=protected)


        getFCThreadNumberChoices(obj)

    end

end


