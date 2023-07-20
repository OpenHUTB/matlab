classdef MSKDemodulator<comm.internal.CPMDemodulatorBase

































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)









        BitOutput=false;
    end

    methods
        function obj=MSKDemodulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.CPMDemodulatorBase();
            setProperties(obj,nargin,varargin{:});


            obj.pFrequencyPulse='Rectangular';
            obj.pModulationOrder=2;
            obj.pSymbolMapping='Binary';
            obj.pModulationIndex=0.5;
            obj.pPulseLength=1;
            obj.pSymbolPrehistory=1;
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndcpm2/MSK Demodulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={'BitOutput',...
            'InitialPhaseOffset',...
            'SamplesPerSymbol',...
            'TracebackDepth',...
            'OutputDataType'};
        end
    end
end
