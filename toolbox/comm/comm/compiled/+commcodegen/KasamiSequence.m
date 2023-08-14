classdef KasamiSequence<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Polynomial
InitialConditions
Index
Shift
MaximumOutputSize
SamplesPerFrame
OutputDataType
VariableSizeOutput
ResetInputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=KasamiSequence(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.KasamiSequence.propListManager');
            coder.extrinsic('commcodegen.KasamiSequence.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.KasamiSequence(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=commcodegen.KasamiSequence.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.KasamiSequence.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.KasamiSequence.propListManager(s,'Polynomial',false))
                val=coder.internal.const(commcodegen.KasamiSequence.getFieldFromMxStruct(propValues,'Polynomial'));
                obj.Polynomial=val;
            end
            if~coder.internal.const(commcodegen.KasamiSequence.propListManager(s,'InitialConditions',false))
                val=coder.internal.const(commcodegen.KasamiSequence.getFieldFromMxStruct(propValues,'InitialConditions'));
                obj.InitialConditions=val;
            end
            if~coder.internal.const(commcodegen.KasamiSequence.propListManager(s,'Index',false))
                val=coder.internal.const(commcodegen.KasamiSequence.getFieldFromMxStruct(propValues,'Index'));
                obj.Index=val;
            end
            if~coder.internal.const(commcodegen.KasamiSequence.propListManager(s,'Shift',false))
                val=coder.internal.const(commcodegen.KasamiSequence.getFieldFromMxStruct(propValues,'Shift'));
                obj.Shift=val;
            end
            if~coder.internal.const(commcodegen.KasamiSequence.propListManager(s,'MaximumOutputSize',false))
                val=coder.internal.const(commcodegen.KasamiSequence.getFieldFromMxStruct(propValues,'MaximumOutputSize'));
                obj.MaximumOutputSize=val;
            end
            if~coder.internal.const(commcodegen.KasamiSequence.propListManager(s,'SamplesPerFrame',false))
                val=coder.internal.const(commcodegen.KasamiSequence.getFieldFromMxStruct(propValues,'SamplesPerFrame'));
                obj.SamplesPerFrame=val;
            end
            if~coder.internal.const(commcodegen.KasamiSequence.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.KasamiSequence.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.KasamiSequence.propListManager(s,'VariableSizeOutput',false))
                val=coder.internal.const(commcodegen.KasamiSequence.getFieldFromMxStruct(propValues,'VariableSizeOutput'));
                obj.VariableSizeOutput=val;
            end
            if~coder.internal.const(commcodegen.KasamiSequence.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(commcodegen.KasamiSequence.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Polynomial(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Polynomial),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.KasamiSequence');
            obj.Polynomial=val;
        end
        function set.InitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.KasamiSequence');
            obj.InitialConditions=val;
        end
        function set.Index(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Index),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.KasamiSequence');
            obj.Index=val;
        end
        function set.Shift(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Shift),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.KasamiSequence');
            obj.Shift=val;
        end
        function set.MaximumOutputSize(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaximumOutputSize),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.KasamiSequence');
            obj.MaximumOutputSize=val;
        end
        function set.SamplesPerFrame(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerFrame),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.KasamiSequence');
            obj.SamplesPerFrame=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.KasamiSequence');
            obj.OutputDataType=val;
        end
        function set.VariableSizeOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VariableSizeOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.KasamiSequence');
            obj.VariableSizeOutput=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.KasamiSequence');
            obj.ResetInputPort=val;
        end
        function sObj=getCSFun(obj)
            sObj=obj.cSFunObject;
        end
        function args=getConstructionArgs(obj)
            args=obj.ConstructorArgs;
        end
        function cloneProp(obj,prop,value)
            if coder.internal.const(~coder.target('Rtw'))
                oldFlag=obj.NoTuningBeforeLockingCodeGenError;
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.(prop)=value;
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=oldFlag;
            end
        end
    end
    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            num=getNumInputs(obj.cSFunObject);
        end
        function num=getNumOutputsImpl(obj)
            num=getNumOutputs(obj.cSFunObject);
        end
        function resetImpl(obj)
            reset(obj.cSFunObject);
        end
        function setupImpl(obj,varargin)
            setup(obj.cSFunObject,varargin{:});
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
        end
        function varargout=isInputDirectFeedthroughImpl(obj,varargin)
            [varargout{1:nargout}]=isInputDirectFeedthrough(obj.cSFunObject,varargin{:});
        end
        function varargout=outputImpl(obj,varargin)
            [varargout{1:nargout}]=output(obj.cSFunObject,varargin{:});
        end
        function updateImpl(obj,varargin)
            update(obj.cSFunObject,varargin{:});
        end
        function out=getDiscreteStateImpl(~)
            out.s=1;
            coder.internal.assert(false,'MATLAB:system:getDiscreteStateNotSupported');
        end
        function out=getContinuousStateImpl(~)
            out.s=1;
            coder.internal.assert(false,'MATLAB:system:getContinuousStateNotSupported');
        end
        function setDiscreteStateImpl(~,~)
            coder.internal.assert(false,'MATLAB:system:setDiscreteStateNotSupported');
        end
        function setContinuousStateImpl(~,~)
            coder.internal.assert(false,'MATLAB:system:setContinuousStateNotSupported');
        end
    end
    methods(Static,Hidden)
        function s=propListManager(varargin)














            if nargin>0&&isstruct(varargin{1})
                s=varargin{1};
                fieldName=varargin{2};
                if varargin{3}
                    s.(fieldName)=true;
                else
                    s=isfield(s,fieldName);
                end
            else
                s=struct;
                if nargin>0
                    for ii=1:varargin{1}
                        s.(varargin{ii+1})=true;
                    end
                end
            end
        end
        function y=getFieldFromMxStruct(s,field)







            y=s.(field);
        end
        function result=matlabCodegenUserReadableName
            result='comm.KasamiSequence';
        end
    end
end
