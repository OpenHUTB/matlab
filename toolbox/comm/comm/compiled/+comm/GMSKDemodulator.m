classdef GMSKDemodulator<comm.internal.CPMDemodulatorBase






































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)









        BitOutput=false;
    end
    properties(Dependent,Nontunable)




BandwidthTimeProduct



PulseLength






SymbolPrehistory
    end

    methods
        function obj=GMSKDemodulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.CPMDemodulatorBase();




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
            a='commdigbbndcpm2/GMSK Demodulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={'BitOutput',...
            'BandwidthTimeProduct',...
            'PulseLength',...
            'SymbolPrehistory',...
            'InitialPhaseOffset',...
            'SamplesPerSymbol',...
            'TracebackDepth',...
            'OutputDataType'};
        end
    end
end
