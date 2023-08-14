classdef Conv2ModuleConfig<dnnfpga.config.ConvModuleConfigBase





    properties(Access=public)



    end

    methods
        function obj=Conv2ModuleConfig(varargin)



            obj=obj@dnnfpga.config.ConvModuleConfigBase(varargin{:});



            obj.InputMemorySize=[227,227,3];
            obj.OutputMemorySize=[55,55,96];

        end

    end


    methods(Hidden,Access=public)

        function updateWhenConvThreadNumberChange(obj)%#ok<MANU>

        end

    end


    methods(Access=protected)

        function convThreadNumberChoices=getConvThreadNumberChoices(obj)%#ok<MANU>
            convThreadNumberChoices={4,9,16,25,36,49,64};
        end

    end

end


