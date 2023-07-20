classdef DPSKDemodulator<comm.internal.DemodulatorHardDecision









































































%#function mcomdpskdemod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        ModulationOrder=8;





        PhaseRotation=pi/8;








        SymbolMapping='Gray';
    end

    properties(Nontunable)









        BitOutput=false;
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
    end

    methods

        function obj=DPSKDemodulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.DemodulatorHardDecision('mcomdpskdemod');
            setProperties(obj,nargin,varargin{:},'ModulationOrder','PhaseRotation');
            setVarSizeAllowedStatus(obj,false);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            outputFormatIdx=~obj.BitOutput+1;

            symbolMappingIdx=getIndex(obj.SymbolMappingSet,obj.SymbolMapping);
            outputDataTypeIdx=getOutputDataTypeIndex(obj);



            obj.compSetParameters({...
            obj.ModulationOrder,...
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
            a='commdigbbndpm3/M-DPSK Demodulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ModulationOrder',...
            'PhaseRotation',...
            'BitOutput',...
            'SymbolMapping',...
            'OutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'ModulationOrder','PhaseRotation'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end


