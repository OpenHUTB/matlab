classdef DPSKModulator<matlab.system.SFunSystem































































%#function mcomdpskmod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        ModulationOrder=8;





        PhaseRotation=pi/8;










        SymbolMapping='Gray';



        OutputDataType='double';









        BitInput(1,1)logical=false;
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
        OutputDataTypeSet=comm.CommonSets.getSet('DoubleOrSingle');
    end

    methods

        function obj=DPSKModulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomdpskmod');
            setProperties(obj,nargin,varargin{:},'ModulationOrder','PhaseRotation');
            setVarSizeAllowedStatus(obj,false);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            inputFormatIdx=~obj.BitInput+1;
            symbolMappingIdx=getIndex(obj.SymbolMappingSet,obj.SymbolMapping);
            outputDataTypeIdx=getIndex(obj.OutputDataTypeSet,obj.OutputDataType);



            obj.compSetParameters({...
            obj.ModulationOrder,...
            inputFormatIdx,...
            symbolMappingIdx,...
            obj.PhaseRotation,...
outputDataTypeIdx...
            });
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndpm3/M-DPSK Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ModulationOrder',...
            'PhaseRotation',...
            'BitInput',...
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

