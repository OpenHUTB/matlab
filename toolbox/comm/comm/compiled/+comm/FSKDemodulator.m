classdef FSKDemodulator<matlab.system.SFunSystem















































































%#function mcomfskdemod

    properties(Nontunable)



        ModulationOrder=8;










        SymbolMapping='Gray';




        FrequencySeparation=6;



        SamplesPerSymbol=17;



        SymbolRate=100;







        OutputDataType='double';











        BitOutput(1,1)logical=false;
    end

    properties(Hidden,Transient)
        pIntOutputDataType;
        pBitOutputDataType;
    end
    properties(Access=protected)
        pIntOutputDataTypeSet=comm.CommonSets.getSet('OutDataType');
        pBitOutputDataTypeSet=comm.CommonSets.getSet('LogicalOrDouble');
    end
    properties(Transient,Hidden)
        OutputDataTypeSet=matlab.system.StringSet({'double'});
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
    end

    methods

        function obj=FSKDemodulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomfskdemod');
            setProperties(obj,length(varargin),varargin{:},...
            'ModulationOrder','FrequencySeparation','SymbolRate');
            setVarSizeAllowedStatus(obj,false);
            setForceInputRealToComplex(obj,1,true);




            setSampleTimeIsFramePeriod(obj,true)
        end

        function set.SymbolRate(obj,val)
            validateattributes(val,{'double'},...
            {'finite','scalar','real','positive'},'','SymbolRate');
            obj.SymbolRate=val;
        end

    end

    methods

        function value=get.OutputDataTypeSet(obj)
            if obj.BitOutput
                value=obj.pBitOutputDataTypeSet;
            else
                value=obj.pIntOutputDataTypeSet;
            end
        end

        function set.OutputDataTypeSet(~,~)
        end
    end

    methods(Access=protected)
        function idx=getOutputDataTypeIndex(obj)
            idx=getIndex(obj.OutputDataTypeSet,obj.OutputDataType);
            coder.internal.errorIf(isempty(idx),'comm:system:DemodulatorBase:invalidOutputDataType',obj.OutputDataType,class(obj));
        end
    end

    methods(Hidden)
        function setParameters(obj)

            outputFormatIdx=~obj.BitOutput+1;
            symbolMappingIdx=getIndex(obj.SymbolMappingSet,obj.SymbolMapping);


            outputDataTypeIdx=getOutputDataTypeIndex(obj);
            if obj.BitOutput
                outputDataTypeIdx=1+7*(outputDataTypeIdx>1);
            end



            setSampleRate(obj,obj.SamplesPerSymbol*obj.SymbolRate);



            obj.compSetParameters({...
            obj.ModulationOrder,...
            outputFormatIdx,...
            symbolMappingIdx,...
            obj.FrequencySeparation,...
            obj.SamplesPerSymbol,...
            1,...
            outputDataTypeIdx});
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndfm2/FSK Demodulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ModulationOrder',...
            'BitOutput',...
            'SymbolMapping',...
            'FrequencySeparation',...
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
