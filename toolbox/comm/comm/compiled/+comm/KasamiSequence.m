classdef KasamiSequence<matlab.system.SFunSystem


























































































%#function mcomksgen3

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)












        Polynomial='z^6 + z + 1'










        InitialConditions=[0,0,0,0,0,1]












        Index=0







        Shift=0







        MaximumOutputSize=[10,1]







        SamplesPerFrame=1



        OutputDataType='double'










        VariableSizeOutput(1,1)logical=false





        ResetInputPort(1,1)logical=false
    end

    properties(Constant,Hidden)
        OutputDataTypeSet=comm.CommonSets.getSet('LogicalOrDouble')
    end

    methods
        function obj=KasamiSequence(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomksgen3');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
            setFrameStatus(obj,false);
        end

        function set.SamplesPerFrame(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','integer','positive','finite','scalar'},'',...
            'SamplesPerFrame');
            obj.SamplesPerFrame=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            outDataTypeIdx=3-...
            getIndex(obj.OutputDataTypeSet,obj.OutputDataType);

            [eStr,genPoly,codeIdx,shift]=commblkksgen3(...
            obj,...
            'init',...
            obj.Polynomial,...
            obj.InitialConditions,...
            obj.Index,...
            obj.Shift);
            if(eStr.ecode==1)
                coder.internal.errorIf(true,eStr.eID);
            end




            obj.compSetParameters({...
            genPoly,...
            obj.InitialConditions,...
            codeIdx,...
            shift,...
            double(obj.VariableSizeOutput),...
            1,...
            obj.MaximumOutputSize,...
            1/obj.SamplesPerFrame,...
            obj.SamplesPerFrame,...
            double(obj.ResetInputPort),...
outDataTypeIdx...
            });
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            if obj.VariableSizeOutput
                props={'SamplesPerFrame'};
            else
                props={'MaximumOutputSize'};
            end
            flag=ismember(prop,props);
        end

    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commseqgen3/Kasami Sequence Generator';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'Polynomial',...
            'InitialConditions',...
            'Index',...
            'Shift',...
            'VariableSizeOutput',...
            'MaximumOutputSize',...
            'SamplesPerFrame',...
            'ResetInputPort',...
            'OutputDataType'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end


