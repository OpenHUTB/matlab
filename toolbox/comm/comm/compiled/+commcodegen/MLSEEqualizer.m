classdef MLSEEqualizer<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
ChannelSource
Channel
Constellation
TracebackDepth
TerminationMethod
PreambleSource
Preamble
PostambleSource
Postamble
SamplesPerSymbol
ResetInputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=MLSEEqualizer(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.MLSEEqualizer.propListManager');
            coder.extrinsic('commcodegen.MLSEEqualizer.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.MLSEEqualizer(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Channel');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.MLSEEqualizer.propListManager(numValueOnlyProps,'Channel');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.MLSEEqualizer.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'ChannelSource',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'ChannelSource'));
                obj.ChannelSource=val;
            end
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'Channel',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'Channel'));
                obj.Channel=val;
            end
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'Constellation',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'Constellation'));
                obj.Constellation=val;
            end
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'TracebackDepth',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'TracebackDepth'));
                obj.TracebackDepth=val;
            end
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'TerminationMethod',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'TerminationMethod'));
                obj.TerminationMethod=val;
            end
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'PreambleSource',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'PreambleSource'));
                obj.PreambleSource=val;
            end
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'Preamble',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'Preamble'));
                obj.Preamble=val;
            end
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'PostambleSource',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'PostambleSource'));
                obj.PostambleSource=val;
            end
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'Postamble',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'Postamble'));
                obj.Postamble=val;
            end
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'SamplesPerSymbol',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'SamplesPerSymbol'));
                obj.SamplesPerSymbol=val;
            end
            if~coder.internal.const(commcodegen.MLSEEqualizer.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(commcodegen.MLSEEqualizer.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.ChannelSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ChannelSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
            obj.ChannelSource=val;
        end
        function set.Channel(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Channel),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
            obj.Channel=val;
        end
        function set.Constellation(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Constellation),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
            obj.Constellation=val;
        end
        function set.TracebackDepth(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TracebackDepth),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
            obj.TracebackDepth=val;
        end
        function set.TerminationMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TerminationMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
            obj.TerminationMethod=val;
        end
        function set.PreambleSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PreambleSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
            obj.PreambleSource=val;
        end
        function set.Preamble(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Preamble),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
            obj.Preamble=val;
        end
        function set.PostambleSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PostambleSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
            obj.PostambleSource=val;
        end
        function set.Postamble(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Postamble),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
            obj.Postamble=val;
        end
        function set.SamplesPerSymbol(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerSymbol),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
            obj.SamplesPerSymbol=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.MLSEEqualizer');
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
            result='comm.MLSEEqualizer';
        end
    end
end
