classdef PhaseFrequencyOffset<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
PhaseOffset
FrequencyOffsetSource
SampleRate
    end
    properties
FrequencyOffset
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=PhaseFrequencyOffset(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.PhaseFrequencyOffset.propListManager');
            coder.extrinsic('commcodegen.PhaseFrequencyOffset.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.PhaseFrequencyOffset(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=commcodegen.PhaseFrequencyOffset.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.PhaseFrequencyOffset.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.PhaseFrequencyOffset.propListManager(s,'PhaseOffset',false))
                val=coder.internal.const(commcodegen.PhaseFrequencyOffset.getFieldFromMxStruct(propValues,'PhaseOffset'));
                obj.PhaseOffset=val;
            end
            if~coder.internal.const(commcodegen.PhaseFrequencyOffset.propListManager(s,'FrequencyOffsetSource',false))
                val=coder.internal.const(commcodegen.PhaseFrequencyOffset.getFieldFromMxStruct(propValues,'FrequencyOffsetSource'));
                obj.FrequencyOffsetSource=val;
            end
            if~coder.internal.const(commcodegen.PhaseFrequencyOffset.propListManager(s,'SampleRate',false))
                val=coder.internal.const(commcodegen.PhaseFrequencyOffset.getFieldFromMxStruct(propValues,'SampleRate'));
                obj.SampleRate=val;
            end
            if~coder.internal.const(commcodegen.PhaseFrequencyOffset.propListManager(s,'FrequencyOffset',false))
                val=coder.internal.const(commcodegen.PhaseFrequencyOffset.getFieldFromMxStruct(propValues,'FrequencyOffset'));
                obj.FrequencyOffset=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.FrequencyOffset(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'FrequencyOffset',val,noTuningError);%#ok<MCSUP>
            obj.FrequencyOffset=val;
        end
        function set.PhaseOffset(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseOffset),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PhaseFrequencyOffset');
            obj.PhaseOffset=val;
        end
        function set.FrequencyOffsetSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FrequencyOffsetSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PhaseFrequencyOffset');
            obj.FrequencyOffsetSource=val;
        end
        function set.SampleRate(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SampleRate),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PhaseFrequencyOffset');
            obj.SampleRate=val;
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
            result='comm.PhaseFrequencyOffset';
        end
    end
end
