classdef CPFSKModulator<comm.internal.CPMModulatorBase











































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)
















        BitInput=false;
    end
    properties(Dependent,Nontunable)



ModulationOrder








SymbolMapping






ModulationIndex
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
    end

    methods
        function obj=CPFSKModulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.CPMModulatorBase(varargin{:});
            setProperties(obj,nargin,varargin{:},'ModulationOrder');


            obj.pFrequencyPulse='Rectangular';
            obj.pPulseLength=1;
            obj.pSymbolPrehistory=1;
        end


        function set.ModulationOrder(obj,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','finite','integer'},'',...
            'ModulationOrder');
            obj.pModulationOrder=value;
        end
        function value=get.ModulationOrder(obj)
            value=obj.pModulationOrder;
        end

        function set.SymbolMapping(obj,value)
            obj.pSymbolMapping=value;
        end
        function value=get.SymbolMapping(obj)
            value=obj.pSymbolMapping;
        end

        function set.ModulationIndex(obj,value)
            obj.pModulationIndex=value;
        end
        function value=get.ModulationIndex(obj)
            value=obj.pModulationIndex;
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~obj.BitInput
                props={'SymbolMapping'};
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndcpm2/CPFSK Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ModulationOrder',...
            'BitInput',...
            'SymbolMapping',...
            'ModulationIndex',...
            'InitialPhaseOffset',...
            'SamplesPerSymbol',...
            'OutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'ModulationOrder'};
        end
    end
end
