classdef DBPSKModulator<matlab.system.SFunSystem
























































%#function mcomdpskmod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)





        PhaseRotation=0;



        OutputDataType='double';
    end

    properties(Constant,Hidden)
        OutputDataTypeSet=comm.CommonSets.getSet('DoubleOrSingle');
    end

    methods

        function obj=DBPSKModulator(varargin)
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

            outputDataTypeIdx=getIndex(obj.OutputDataTypeSet,obj.OutputDataType);



            obj.compSetParameters({...
            2,...
            1,...
            1,...
            obj.PhaseRotation,...
outputDataTypeIdx...
            });
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndpm3/DBPSK Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'PhaseRotation',...
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

