classdef GMSKModulator<comm.internal.CPMModulatorBase





































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)







        BitInput=false;
    end
    properties(Dependent,Nontunable)




        BandwidthTimeProduct=0.3;



        PulseLength=4;






        SymbolPrehistory=1;
    end

    methods
        function obj=GMSKModulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.CPMModulatorBase(varargin{:});



            obj.pPulseLength=4;
            setProperties(obj,nargin,varargin{:});


            obj.pFrequencyPulse='Gaussian';
            obj.pModulationOrder=2;
            obj.pSymbolMapping='Binary';
            obj.pModulationIndex=0.5;
        end

        function set.BandwidthTimeProduct(obj,value)
            obj.pBandwidthTimeProduct=value;
        end
        function value=get.BandwidthTimeProduct(obj)
            value=obj.pBandwidthTimeProduct;
        end

        function set.PulseLength(obj,value)
            validateattributes(value,{'double'},...
            {'real','scalar','finite','integer','positive'},'',...
            'PulseLength');
            obj.pPulseLength=value;
        end
        function value=get.PulseLength(obj)
            value=obj.pPulseLength;
        end

        function set.SymbolPrehistory(obj,value)
            obj.pSymbolPrehistory=value;
        end
        function value=get.SymbolPrehistory(obj)
            value=obj.pSymbolPrehistory;
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndcpm2/GMSK Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={'BitInput',...
            'BandwidthTimeProduct',...
            'PulseLength',...
            'SymbolPrehistory',...
            'InitialPhaseOffset',...
            'SamplesPerSymbol',...
            'OutputDataType'};
        end
    end
end
