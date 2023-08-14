classdef Counter<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Direction
CountEventCondition
CounterSizeSource
CounterSize
SamplesPerFrame
CountOutputDataType
CountEventInputPort
CountOutputPort
HitOutputPort
ResetInputPort
    end
    properties
MaximumCount
InitialCount
HitValues
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=Counter(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.Counter.propListManager');
            coder.extrinsic('dspcodegen.Counter.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.Counter(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.Counter.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.Counter.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'Direction',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'Direction'));
                obj.Direction=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'CountEventCondition',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'CountEventCondition'));
                obj.CountEventCondition=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'CounterSizeSource',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'CounterSizeSource'));
                obj.CounterSizeSource=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'CounterSize',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'CounterSize'));
                obj.CounterSize=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'SamplesPerFrame',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'SamplesPerFrame'));
                obj.SamplesPerFrame=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'CountOutputDataType',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'CountOutputDataType'));
                obj.CountOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'CountEventInputPort',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'CountEventInputPort'));
                obj.CountEventInputPort=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'CountOutputPort',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'CountOutputPort'));
                obj.CountOutputPort=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'HitOutputPort',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'HitOutputPort'));
                obj.HitOutputPort=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'MaximumCount',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'MaximumCount'));
                obj.MaximumCount=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'InitialCount',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'InitialCount'));
                obj.InitialCount=val;
            end
            if~coder.internal.const(dspcodegen.Counter.propListManager(s,'HitValues',false))
                val=coder.internal.const(dspcodegen.Counter.getFieldFromMxStruct(propValues,'HitValues'));
                obj.HitValues=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.MaximumCount(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'MaximumCount',val,noTuningError);%#ok<MCSUP>
            obj.MaximumCount=val;
        end
        function set.InitialCount(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'InitialCount',val,noTuningError);%#ok<MCSUP>
            obj.InitialCount=val;
        end
        function set.HitValues(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'HitValues',val,noTuningError);%#ok<MCSUP>
            obj.HitValues=val;
        end
        function set.Direction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Direction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Counter');
            obj.Direction=val;
        end
        function set.CountEventCondition(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CountEventCondition),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Counter');
            obj.CountEventCondition=val;
        end
        function set.CounterSizeSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CounterSizeSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Counter');
            obj.CounterSizeSource=val;
        end
        function set.CounterSize(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CounterSize),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Counter');
            obj.CounterSize=val;
        end
        function set.SamplesPerFrame(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerFrame),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Counter');
            obj.SamplesPerFrame=val;
        end
        function set.CountOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CountOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Counter');
            obj.CountOutputDataType=val;
        end
        function set.CountEventInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CountEventInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Counter');
            obj.CountEventInputPort=val;
        end
        function set.CountOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CountOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Counter');
            obj.CountOutputPort=val;
        end
        function set.HitOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.HitOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Counter');
            obj.HitOutputPort=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Counter');
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
            result='dsp.Counter';
        end
    end
end
