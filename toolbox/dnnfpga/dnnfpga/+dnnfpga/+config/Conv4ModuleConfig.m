classdef Conv4ModuleConfig<dnnfpga.config.ConvModuleConfigBase





    properties(Hidden)




FilterSizeLimit


KernelDataType


RoundingMode






        SyncInstructionNumber=2^13;

    end

    properties(Hidden,Dependent)


    end

    properties(Hidden,GetAccess=public,SetAccess=protected)









        WeightAXIDataBitwidth=128;


ActivationAXIDataBitwidth

    end

    properties(Constant,Hidden)

        FilterSizeLimitDefault=36;
        KernelDataTypeChoices={'single','int8','int4'};
        KernelDataTypeDefault='single';
        RoundingModeChoices={'Ceiling','Convergent','Floor','Nearest','Round','Zero'};
        RoundingModeDefault='Round';

    end

    methods
        function obj=Conv4ModuleConfig(varargin)



            obj=obj@dnnfpga.config.ConvModuleConfigBase(varargin{:});



            obj.addprop('LRNBlockGeneration');
            obj.addprop('SegmentationBlockGeneration');



            p=obj.Properties('TopLevelProperties');
            p{end+1}='FilterSizeLimit';
            p{end+1}='KernelDataType';
            p{end+1}='RoundingMode';
            p{end+1}='ActivationAXIDataBitwidth';
            p{end+1}='WeightAXIDataBitwidth';
            p{end+1}='SyncInstructionNumber';
            obj.Properties('TopLevelProperties')=p;


            p=obj.Properties(obj.ModuleGenerationMapKeyName);
            p{end+1}='LRNBlockGeneration';
            p{end+1}='SegmentationBlockGeneration';
            obj.Properties(obj.ModuleGenerationMapKeyName)=p;


            obj.HiddenProperties('FilterSizeLimit')=true;
            obj.HiddenProperties('KernelDataType')=true;
            obj.HiddenProperties('RoundingMode')=true;
            obj.HiddenProperties('ActivationAXIDataBitwidth')=true;
            obj.HiddenProperties('WeightAXIDataBitwidth')=true;
            obj.HiddenProperties('SyncInstructionNumber')=true;



            obj.FilterSizeLimit=obj.FilterSizeLimitDefault;


            obj.KernelDataType=obj.KernelDataTypeDefault;

            obj.RoundingMode=obj.RoundingModeDefault;


            obj.updateActivationAXIDataBitwidth;





            obj.InputMemorySize=[227,227,3];
            obj.OutputMemorySize=[227,227,3];



            obj.LRNBlockGeneration=~obj.ModuleGenerationDefault;
            obj.SegmentationBlockGeneration=obj.ModuleGenerationDefault;
        end

        function validateModuleConfig(obj)



        end

    end


    methods
        function set.FilterSizeLimit(obj,val)
            filterSizeMultipleOf=3;
            dnnfpga.config.validatePositiveIntegerPropertyMultiple(val,'FilterSizeLimit',...
            filterSizeMultipleOf,obj.FilterSizeLimitDefault);
            obj.FilterSizeLimit=val;
        end
        function set.KernelDataType(obj,val)
            dnnfpga.config.validateStringPropertyValue(val,'KernelDataType',...
            obj.KernelDataTypeChoices,obj.KernelDataTypeDefault)
            obj.KernelDataType=val;



            obj.updateActivationAXIDataBitwidth;
        end
        function set.SyncInstructionNumber(obj,val)




            minSyncInstNum=2^1;
            maxSyncInstNum=2^32;

            dnnfpga.config.validatePositiveIntegerPropertyRange(val,'SyncInstructionNumber',...
            [minSyncInstNum,maxSyncInstNum],obj.SyncInstructionNumber);
            obj.SyncInstructionNumber=val;
        end

        function set.RoundingMode(obj,val)
            dnnfpga.config.validateStringPropertyValue(val,'RoundingMode',...
            obj.RoundingModeChoices,obj.RoundingModeDefault)
            obj.RoundingMode=val;
        end
    end


    methods(Hidden,Access=public)

        function updateActivationAXIDataBitwidth(obj)



            convThreadInternal=sqrt(obj.ConvThreadNumber);
            convThreadInternalP2N=2^(ceil(log2(convThreadInternal)));

            if strcmpi(obj.KernelDataType,'single')
                obj.ActivationAXIDataBitwidth=32*convThreadInternalP2N;
            else




                obj.ActivationAXIDataBitwidth=8*convThreadInternalP2N;
            end
        end

        function updateWhenConvThreadNumberChange(obj)


            obj.updateActivationAXIDataBitwidth;
        end

    end


    methods
    end


    methods(Access=protected)

        function convThreadNumberChoices=getConvThreadNumberChoices(obj)
            if strcmpi(obj.KernelDataType,'single')
                convThreadNumberChoices={4,9,16,25,36,49,64};
            else

                convThreadNumberChoices={4,9,16,25,36,49,64,256};
            end
        end

    end

end


