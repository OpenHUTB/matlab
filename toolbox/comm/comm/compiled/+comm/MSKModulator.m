classdef MSKModulator<comm.internal.CPMModulatorBase


































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)







        BitInput=false;
    end


    methods
        function obj=MSKModulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.CPMModulatorBase(varargin{:});
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
            a='commdigbbndcpm2/MSK Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={'BitInput',...
            'InitialPhaseOffset',...
            'SamplesPerSymbol',...
            'OutputDataType'};
        end
    end
end
