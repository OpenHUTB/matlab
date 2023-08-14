classdef DelayLine<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Length
InitialConditions
DirectFeedthrough
EnableOutputInputPort
HoldPreviousValue
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=DelayLine(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.DelayLine.propListManager');
            coder.extrinsic('dspcodegen.DelayLine.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.DelayLine(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Length','InitialConditions');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=dspcodegen.DelayLine.propListManager(numValueOnlyProps,'Length','InitialConditions');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.DelayLine.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.DelayLine.propListManager(s,'Length',false))
                val=coder.internal.const(dspcodegen.DelayLine.getFieldFromMxStruct(propValues,'Length'));
                obj.Length=val;
            end
            if~coder.internal.const(dspcodegen.DelayLine.propListManager(s,'InitialConditions',false))
                val=coder.internal.const(dspcodegen.DelayLine.getFieldFromMxStruct(propValues,'InitialConditions'));
                obj.InitialConditions=val;
            end
            if~coder.internal.const(dspcodegen.DelayLine.propListManager(s,'DirectFeedthrough',false))
                val=coder.internal.const(dspcodegen.DelayLine.getFieldFromMxStruct(propValues,'DirectFeedthrough'));
                obj.DirectFeedthrough=val;
            end
            if~coder.internal.const(dspcodegen.DelayLine.propListManager(s,'EnableOutputInputPort',false))
                val=coder.internal.const(dspcodegen.DelayLine.getFieldFromMxStruct(propValues,'EnableOutputInputPort'));
                obj.EnableOutputInputPort=val;
            end
            if~coder.internal.const(dspcodegen.DelayLine.propListManager(s,'HoldPreviousValue',false))
                val=coder.internal.const(dspcodegen.DelayLine.getFieldFromMxStruct(propValues,'HoldPreviousValue'));
                obj.HoldPreviousValue=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Length(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Length),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DelayLine');
            obj.Length=val;
        end
        function set.InitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DelayLine');
            obj.InitialConditions=val;
        end
        function set.DirectFeedthrough(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DirectFeedthrough),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DelayLine');
            obj.DirectFeedthrough=val;
        end
        function set.EnableOutputInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.EnableOutputInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DelayLine');
            obj.EnableOutputInputPort=val;
        end
        function set.HoldPreviousValue(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.HoldPreviousValue),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DelayLine');
            obj.HoldPreviousValue=val;
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
            result='dsp.DelayLine';
        end
    end
end
