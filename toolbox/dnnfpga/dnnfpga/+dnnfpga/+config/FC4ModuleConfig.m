classdef FC4ModuleConfig<dnnfpga.config.FCModuleConfigBase





    properties(Hidden)



KernelDataType

RoundingMode
    end

    properties(Hidden,GetAccess=public,SetAccess=protected)



WeightAXIDataBitwidth

    end


    properties(Constant,Hidden)

        KernelDataTypeChoices={'single','int8','int4'};
        KernelDataTypeDefault='single';
        RoundingModeChoices={'Ceiling','Convergent','Floor','Nearest','Round','Zero'};
        RoundingModeDefault='Round';

    end

    methods
        function obj=FC4ModuleConfig(varargin)



            obj=obj@dnnfpga.config.FCModuleConfigBase(varargin{:});



            obj.addprop('SoftmaxBlockGeneration');
            obj.addprop('SigmoidBlockGeneration');
            obj.SoftmaxBlockGeneration=~obj.ModuleGenerationDefault;
            obj.SigmoidBlockGeneration=~obj.ModuleGenerationDefault;



            p=obj.Properties('TopLevelProperties');
            p{end+1}='KernelDataType';
            p{end+1}='RoundingMode';
            p{end+1}='WeightAXIDataBitwidth';

            obj.Properties('TopLevelProperties')=p;


            p=obj.Properties(obj.ModuleGenerationMapKeyName);
            p{end+1}='SoftmaxBlockGeneration';
            p{end+1}='SigmoidBlockGeneration';
            obj.Properties(obj.ModuleGenerationMapKeyName)=p;


            obj.HiddenProperties('KernelDataType')=true;
            obj.HiddenProperties('RoundingMode')=true;
            obj.HiddenProperties('WeightAXIDataBitwidth')=true;




            obj.KernelDataType=obj.KernelDataTypeDefault;

            obj.RoundingMode=obj.RoundingModeDefault;


            obj.updateWeightAXIDataBitwidth;
        end

    end


    methods
        function set.KernelDataType(obj,val)
            dnnfpga.config.validateStringPropertyValue(val,'KernelDataType',...
            obj.KernelDataTypeChoices,obj.KernelDataTypeDefault)
            obj.KernelDataType=val;



            obj.updateWeightAXIDataBitwidth;
        end

        function set.RoundingMode(obj,val)
            dnnfpga.config.validateStringPropertyValue(val,'RoundingMode',...
            obj.RoundingModeChoices,obj.RoundingModeDefault)
            obj.RoundingMode=val;
        end

    end


    methods(Hidden,Access=public)

        function updateWeightAXIDataBitwidth(obj)


            if strcmpi(obj.KernelDataType,'single')
                obj.WeightAXIDataBitwidth=32*obj.FCThreadNumber;
            else




                obj.WeightAXIDataBitwidth=8*obj.FCThreadNumber;
            end
        end

        function updateWhenFCThreadNumberChange(obj)


            obj.updateWeightAXIDataBitwidth;
        end

    end


    methods(Access=protected)

        function fcThreadNumberChoices=getFCThreadNumberChoices(obj)
            if strcmpi(obj.KernelDataType,'single')
                fcThreadNumberChoices={4,8,16};
            else

                fcThreadNumberChoices={4,8,16,32,64};
            end
        end

    end

    methods

    end
end


