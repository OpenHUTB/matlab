classdef(Abstract)CustomLayerModuleConfigBase<dnnfpga.config.ModuleConfigBase





    properties




InputMemorySize
OutputMemorySize

    end

    properties(Hidden,Dependent,GetAccess=public,SetAccess=protected)



InputBurstLength
OutputBurstLength
    end


    properties(Constant,Hidden)

        InputMemorySizeDefault=40;
        OutputMemorySizeDefault=120;

    end


    properties(Hidden,Constant)
        DefaultModuleID='custom'
    end

    methods
        function obj=CustomLayerModuleConfigBase(varargin)



            propList={...
            {'ModuleID',dnnfpga.config.CustomLayerModuleConfigBase.DefaultModuleID},...
            };


            p=downstream.tool.parseInputProperties(propList,varargin{:});
            inputArgs=p.Results;


            moduleID=inputArgs.ModuleID;
            obj=obj@dnnfpga.config.ModuleConfigBase(moduleID);


            obj.InputMemorySize=obj.InputMemorySizeDefault;
            obj.OutputMemorySize=obj.OutputMemorySizeDefault;




            obj.Properties('TopLevelProperties')=cat(2,{...
            'InputMemorySize',...
            'OutputMemorySize',...
            'InputBurstLength',...
            'OutputBurstLength',...
            },obj.Properties('TopLevelProperties'));

            obj.HiddenProperties('InputBurstLength')=true;
            obj.HiddenProperties('OutputBurstLength')=true;
        end

        function updateModuleGenerationProperties(obj,name)


            p=obj.Properties(obj.ModuleGenerationMapKeyName);
            p{end+1}=name;
            obj.Properties(obj.ModuleGenerationMapKeyName)=p;

            if(strcmpi(name,'Exponential'))
                obj.HiddenProperties('Exponential')=true;
            end
            if(strcmpi(name,'Identity'))
                obj.HiddenProperties('Identity')=true;
            end
        end

    end


    methods

        function value=get.InputBurstLength(obj)


            value=floor(obj.InputMemorySize/2);
        end

        function value=get.OutputBurstLength(obj)




            value=floor(min(obj.InputMemorySize,obj.OutputMemorySize)/2);
        end

        function set.InputMemorySize(obj,val)
            dnnfpga.config.validatePositiveIntegerProperty(val,'InputMemorySize',...
            obj.InputMemorySizeDefault);
            obj.InputMemorySize=val;
        end

        function set.OutputMemorySize(obj,val)

            dnnfpga.config.validatePositiveIntegerProperty(val,'OutputMemorySize',...
            obj.OutputMemorySizeDefault);
            obj.OutputMemorySize=val;
        end

    end


    methods(Abstract,Access=protected)

    end


    methods(Abstract,Access=protected)

    end

end


