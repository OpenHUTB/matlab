classdef DQPSKModulator<matlab.system.SFunSystem


























































%#function mcomdpskmod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)





        PhaseRotation=pi/4;









        SymbolMapping='Gray';



        OutputDataType='double';








        BitInput(1,1)logical=false;
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
        OutputDataTypeSet=comm.CommonSets.getSet('DoubleOrSingle');
    end

    methods

        function obj=DQPSKModulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomdpskmod');
            setProperties(obj,nargin,varargin{:},'PhaseRotation');
            setVarSizeAllowedStatus(obj,false);
        end

        function set.PhaseRotation(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','scalar','finite'},'',...
            'PhaseRotation');
            obj.PhaseRotation=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            inputFormatIdx=~obj.BitInput+1;
            symbolMappingIdx=getIndex(obj.SymbolMappingSet,obj.SymbolMapping);
            outputDataTypeIdx=getIndex(obj.OutputDataTypeSet,obj.OutputDataType);



            obj.compSetParameters({...
            4,...
            inputFormatIdx,...
            symbolMappingIdx,...
            obj.PhaseRotation,...
outputDataTypeIdx...
            });
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndpm3/DQPSK Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'PhaseRotation',...
            'BitInput',...
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

