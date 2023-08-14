classdef FSKModulator<matlab.system.SFunSystem































































































%#function mcomfskmod

    properties(Nontunable)



        ModulationOrder=8;










        SymbolMapping='Gray';






        FrequencySeparation=6;




        SamplesPerSymbol=17;







        SymbolRate=100;



        OutputDataType='double';











        BitInput(1,1)logical=false;








        ContinuousPhase(1,1)logical=true;
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
        OutputDataTypeSet=comm.CommonSets.getSet('DoubleOrSingle');
    end

    methods

        function obj=FSKModulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomfskmod');
            setProperties(obj,nargin,varargin{:},'ModulationOrder','FrequencySeparation','SymbolRate');
            setVarSizeAllowedStatus(obj,false);




            setSampleTimeIsFramePeriod(obj,true)
        end

        function set.SymbolRate(obj,val)
            validateattributes(val,{'double'},...
            {'finite','scalar','real','positive'},'','SymbolRate');
            obj.SymbolRate=val;
        end

        function set.ModulationOrder(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','scalar','finite','integer','>=',2},'',...
            'ModulationOrder');
            obj.ModulationOrder=val;
        end

        function set.FrequencySeparation(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','scalar','finite','positive'},'',...
            'FrequencySeparation');
            obj.FrequencySeparation=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            inputFormatIdx=~obj.BitInput+1;
            symbolMappingIdx=getIndex(obj.SymbolMappingSet,obj.SymbolMapping);
            phaseType=~obj.ContinuousPhase+1;
            outputDataTypeIdx=getIndex(obj.OutputDataTypeSet,...
            obj.OutputDataType);


            sampleRate=obj.SymbolRate;
            if obj.BitInput

                sampleRate=sampleRate*log2(obj.ModulationOrder);
            end
            setSampleRate(obj,sampleRate);



            obj.compSetParameters({...
            obj.ModulationOrder,...
            inputFormatIdx,...
            symbolMappingIdx,...
            obj.FrequencySeparation,...
            phaseType,...
            obj.SamplesPerSymbol,...
            1,...
            outputDataTypeIdx});
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndfm2/FSK Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ModulationOrder',...
            'BitInput',...
            'SymbolMapping',...
            'FrequencySeparation',...
            'ContinuousPhase',...
            'SamplesPerSymbol',...
            'SymbolRate',...
            'OutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'ModulationOrder','FrequencySeparation','SymbolRate'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end
