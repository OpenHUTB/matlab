classdef FCModuleConfig<dnnfpga.config.FCModuleConfigBase





    properties(Access=public)


        WeightDataType='single';

    end

    properties(Hidden)


        WeightAXIDataBitwidth=128;

    end

    methods
        function obj=FCModuleConfig(varargin)



            obj=obj@dnnfpga.config.FCModuleConfigBase(varargin{:});



            p=obj.Properties('TopLevelProperties');
            p{end+1}='WeightDataType';
            p{end+1}='WeightAXIDataBitwidth';

            obj.Properties('TopLevelProperties')=p;


            obj.HiddenProperties('WeightAXIDataBitwidth')=true;

        end

    end


    methods(Hidden,Access=public)

        function updateWhenFCThreadNumberChange(obj)%#ok<MANU>

        end

    end


    methods(Access=protected)

        function fcThreadNumberChoices=getFCThreadNumberChoices(obj)%#ok<MANU>
            fcThreadNumberChoices={4,8,16};
        end

    end


end



