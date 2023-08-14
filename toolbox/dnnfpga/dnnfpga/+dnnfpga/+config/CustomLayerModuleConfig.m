classdef CustomLayerModuleConfig<dnnfpga.config.CustomLayerModuleConfigBase





    properties(Access=public)

    end

    properties



KernelDataType
    end


    properties(Constant,Hidden)

        KernelDataTypeChoices={'single','int8','int4'};
        KernelDataTypeDefault='single';
        DefaultOffModules={'Sigmoid','TanhLayer','Exponential','Identity','Resize2D'};

    end

    methods
        function obj=CustomLayerModuleConfig(varargin)



            obj=obj@dnnfpga.config.CustomLayerModuleConfigBase(varargin{:});



            p=obj.Properties('TopLevelProperties');
            p{end+1}='KernelDataType';

            obj.Properties('TopLevelProperties')=p;



            obj.KernelDataType=obj.KernelDataTypeDefault;

            obj.HiddenProperties('KernelDataType')=true;
        end

    end


    methods
        function set.KernelDataType(obj,val)
            dnnfpga.config.validateStringPropertyValue(val,'KernelDataType',...
            obj.KernelDataTypeChoices,obj.KernelDataTypeDefault)
            obj.KernelDataType=val;
        end
    end

end



