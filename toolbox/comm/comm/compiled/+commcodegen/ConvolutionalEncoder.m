classdef ConvolutionalEncoder<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
TrellisStructure
TerminationMethod
PuncturePatternSource
PuncturePattern
ResetInputPort
DelayedResetAction
InitialStateInputPort
FinalStateOutputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=ConvolutionalEncoder(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.ConvolutionalEncoder.propListManager');
            coder.extrinsic('commcodegen.ConvolutionalEncoder.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.ConvolutionalEncoder(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'TrellisStructure');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.ConvolutionalEncoder.propListManager(numValueOnlyProps,'TrellisStructure');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.ConvolutionalEncoder.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.ConvolutionalEncoder.propListManager(s,'TrellisStructure',false))
                val=coder.internal.const(commcodegen.ConvolutionalEncoder.getFieldFromMxStruct(propValues,'TrellisStructure'));
                obj.TrellisStructure=val;
            end
            if~coder.internal.const(commcodegen.ConvolutionalEncoder.propListManager(s,'TerminationMethod',false))
                val=coder.internal.const(commcodegen.ConvolutionalEncoder.getFieldFromMxStruct(propValues,'TerminationMethod'));
                obj.TerminationMethod=val;
            end
            if~coder.internal.const(commcodegen.ConvolutionalEncoder.propListManager(s,'PuncturePatternSource',false))
                val=coder.internal.const(commcodegen.ConvolutionalEncoder.getFieldFromMxStruct(propValues,'PuncturePatternSource'));
                obj.PuncturePatternSource=val;
            end
            if~coder.internal.const(commcodegen.ConvolutionalEncoder.propListManager(s,'PuncturePattern',false))
                val=coder.internal.const(commcodegen.ConvolutionalEncoder.getFieldFromMxStruct(propValues,'PuncturePattern'));
                obj.PuncturePattern=val;
            end
            if~coder.internal.const(commcodegen.ConvolutionalEncoder.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(commcodegen.ConvolutionalEncoder.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if~coder.internal.const(commcodegen.ConvolutionalEncoder.propListManager(s,'DelayedResetAction',false))
                val=coder.internal.const(commcodegen.ConvolutionalEncoder.getFieldFromMxStruct(propValues,'DelayedResetAction'));
                obj.DelayedResetAction=val;
            end
            if~coder.internal.const(commcodegen.ConvolutionalEncoder.propListManager(s,'InitialStateInputPort',false))
                val=coder.internal.const(commcodegen.ConvolutionalEncoder.getFieldFromMxStruct(propValues,'InitialStateInputPort'));
                obj.InitialStateInputPort=val;
            end
            if~coder.internal.const(commcodegen.ConvolutionalEncoder.propListManager(s,'FinalStateOutputPort',false))
                val=coder.internal.const(commcodegen.ConvolutionalEncoder.getFieldFromMxStruct(propValues,'FinalStateOutputPort'));
                obj.FinalStateOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.TrellisStructure(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TrellisStructure),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ConvolutionalEncoder');
            obj.TrellisStructure=val;
        end
        function set.TerminationMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TerminationMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ConvolutionalEncoder');
            obj.TerminationMethod=val;
        end
        function set.PuncturePatternSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PuncturePatternSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ConvolutionalEncoder');
            obj.PuncturePatternSource=val;
        end
        function set.PuncturePattern(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PuncturePattern),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ConvolutionalEncoder');
            obj.PuncturePattern=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ConvolutionalEncoder');
            obj.ResetInputPort=val;
        end
        function set.DelayedResetAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DelayedResetAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ConvolutionalEncoder');
            obj.DelayedResetAction=val;
        end
        function set.InitialStateInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialStateInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ConvolutionalEncoder');
            obj.InitialStateInputPort=val;
        end
        function set.FinalStateOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FinalStateOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.ConvolutionalEncoder');
            obj.FinalStateOutputPort=val;
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
            result='comm.ConvolutionalEncoder';
        end
    end
end
