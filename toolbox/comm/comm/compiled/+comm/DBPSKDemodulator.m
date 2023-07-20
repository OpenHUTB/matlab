classdef DBPSKDemodulator<matlab.system.SFunSystem
































































%#function mcomdpskdemod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)





        PhaseRotation=0;







        OutputDataType='Full precision';
    end

    properties(Constant,Hidden)
        OutputDataTypeSet=comm.CommonSets.getSet('BitDataType');
    end

    methods

        function obj=DBPSKDemodulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomdpskdemod');
            setProperties(obj,nargin,varargin{:},'PhaseRotation');
            setVarSizeAllowedStatus(obj,false);
            setForceInputRealToComplex(obj,1,true);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            outputDataTypeIdx=getIndex(obj.OutputDataTypeSet,...
            obj.OutputDataType);



            obj.compSetParameters({...
            2,...
            1,...
            1,...
            0,...
            obj.PhaseRotation,...
            outputDataTypeIdx,...
            });
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndpm3/DBPSK Demodulator Baseband';
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

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            if strcmp(obj.OutputDataType,'Full precision')
                setPortDataTypeConnection(obj,1,1);
            end
        end
    end

end
