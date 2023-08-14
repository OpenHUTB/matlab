classdef DQPSKDemodulator<comm.internal.DemodulatorHardDecision


































































%#function mcomdpskdemod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)





        PhaseRotation=pi/4;







        SymbolMapping='Gray';
    end

    properties(Nontunable)








        BitOutput=false;
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
    end

    methods

        function obj=DQPSKDemodulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.DemodulatorHardDecision('mcomdpskdemod');
            setProperties(obj,nargin,varargin{:},'PhaseRotation');
            setVarSizeAllowedStatus(obj,false);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            outputFormatIdx=~obj.BitOutput+1;
            symbolMappingIdx=getIndex(obj.SymbolMappingSet,obj.SymbolMapping);
            outputDataTypeIdx=getOutputDataTypeIndex(obj);



            obj.compSetParameters({...
            4,...
            outputFormatIdx,...
            symbolMappingIdx,...
            0,...
            obj.PhaseRotation,...
            outputDataTypeIdx,...
            });
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndpm3/DQPSK Demodulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'PhaseRotation',...
            'BitOutput',...
            'SymbolMapping',...
            'OutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'PhaseRotation'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end



