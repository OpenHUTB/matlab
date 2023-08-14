classdef ViterbiDecoder<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
TrellisStructure
InputFormat
SoftInputWordLength
InvalidQuantizedInputAction
TracebackDepth
TerminationMethod
PuncturePatternSource
PuncturePattern
OutputDataType
StateMetricDataType
CustomStateMetricDataType
ResetInputPort
DelayedResetAction
ErasuresInputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=ViterbiDecoder(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.ViterbiDecoder.propListManager');
            coder.extrinsic('commcodegen.ViterbiDecoder.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.ViterbiDecoder(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'TrellisStructure');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.ViterbiDecoder.propListManager(numValueOnlyProps,'TrellisStructure');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.ViterbiDecoder.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'TrellisStructure',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'TrellisStructure'));
                obj.TrellisStructure=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'InputFormat',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'InputFormat'));
                obj.InputFormat=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'SoftInputWordLength',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'SoftInputWordLength'));
                obj.SoftInputWordLength=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'InvalidQuantizedInputAction',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'InvalidQuantizedInputAction'));
                obj.InvalidQuantizedInputAction=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'TracebackDepth',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'TracebackDepth'));
                obj.TracebackDepth=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'TerminationMethod',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'TerminationMethod'));
                obj.TerminationMethod=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'PuncturePatternSource',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'PuncturePatternSource'));
                obj.PuncturePatternSource=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'PuncturePattern',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'PuncturePattern'));
                obj.PuncturePattern=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'StateMetricDataType',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'StateMetricDataType'));
                obj.StateMetricDataType=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'CustomStateMetricDataType',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'CustomStateMetricDataType'));
                obj.CustomStateMetricDataType=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'DelayedResetAction',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'DelayedResetAction'));
                obj.DelayedResetAction=val;
            end
            if~coder.internal.const(commcodegen.ViterbiDecoder.propListManager(s,'ErasuresInputPort',false))
                val=coder.internal.const(commcodegen.ViterbiDecoder.getFieldFromMxStruct(propValues,'ErasuresInputPort'));
                obj.ErasuresInputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.TrellisStructure(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TrellisStructure),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.TrellisStructure=val;
        end
        function set.InputFormat(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InputFormat),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.InputFormat=val;
        end
        function set.SoftInputWordLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SoftInputWordLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.SoftInputWordLength=val;
        end
        function set.InvalidQuantizedInputAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InvalidQuantizedInputAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.InvalidQuantizedInputAction=val;
        end
        function set.TracebackDepth(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TracebackDepth),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.TracebackDepth=val;
        end
        function set.TerminationMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TerminationMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.TerminationMethod=val;
        end
        function set.PuncturePatternSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PuncturePatternSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.PuncturePatternSource=val;
        end
        function set.PuncturePattern(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PuncturePattern),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.PuncturePattern=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.OutputDataType=val;
        end
        function set.StateMetricDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.StateMetricDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.StateMetricDataType=val;
        end
        function set.CustomStateMetricDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomStateMetricDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.CustomStateMetricDataType=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.ResetInputPort=val;
        end
        function set.DelayedResetAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DelayedResetAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.DelayedResetAction=val;
        end
        function set.ErasuresInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ErasuresInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ViterbiDecoder');
            obj.ErasuresInputPort=val;
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
            result='comm.ViterbiDecoder';
        end
    end
end
