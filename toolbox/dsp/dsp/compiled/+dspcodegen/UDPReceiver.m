classdef UDPReceiver<matlab.System&matlab.system.mixin.FiniteSource
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
RemoteIPAddress
ReceiveBufferSize
MaximumMessageLength
MessageDataType
IsMessageComplex
BlockingTime
LengthOutputPort
    end
    properties
LocalIPPort
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=UDPReceiver(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.UDPReceiver.propListManager');
            coder.extrinsic('dspcodegen.UDPReceiver.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.UDPReceiver(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.UDPReceiver.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.UDPReceiver.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.UDPReceiver.propListManager(s,'RemoteIPAddress',false))
                val=coder.internal.const(dspcodegen.UDPReceiver.getFieldFromMxStruct(propValues,'RemoteIPAddress'));
                obj.RemoteIPAddress=val;
            end
            if~coder.internal.const(dspcodegen.UDPReceiver.propListManager(s,'ReceiveBufferSize',false))
                val=coder.internal.const(dspcodegen.UDPReceiver.getFieldFromMxStruct(propValues,'ReceiveBufferSize'));
                obj.ReceiveBufferSize=val;
            end
            if~coder.internal.const(dspcodegen.UDPReceiver.propListManager(s,'MaximumMessageLength',false))
                val=coder.internal.const(dspcodegen.UDPReceiver.getFieldFromMxStruct(propValues,'MaximumMessageLength'));
                obj.MaximumMessageLength=val;
            end
            if~coder.internal.const(dspcodegen.UDPReceiver.propListManager(s,'MessageDataType',false))
                val=coder.internal.const(dspcodegen.UDPReceiver.getFieldFromMxStruct(propValues,'MessageDataType'));
                obj.MessageDataType=val;
            end
            if~coder.internal.const(dspcodegen.UDPReceiver.propListManager(s,'IsMessageComplex',false))
                val=coder.internal.const(dspcodegen.UDPReceiver.getFieldFromMxStruct(propValues,'IsMessageComplex'));
                obj.IsMessageComplex=val;
            end
            if~coder.internal.const(dspcodegen.UDPReceiver.propListManager(s,'LocalIPPort',false))
                val=coder.internal.const(dspcodegen.UDPReceiver.getFieldFromMxStruct(propValues,'LocalIPPort'));
                obj.LocalIPPort=val;
            end
            if~coder.internal.const(dspcodegen.UDPReceiver.propListManager(s,'BlockingTime',false))
                val=coder.internal.const(get(obj.cSFunObject,'BlockingTime'));
                obj.BlockingTime=val;
            end
            if~coder.internal.const(dspcodegen.UDPReceiver.propListManager(s,'LengthOutputPort',false))
                val=coder.internal.const(get(obj.cSFunObject,'LengthOutputPort'));
                obj.LengthOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.LocalIPPort(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'LocalIPPort',val,noTuningError);%#ok<MCSUP>
            obj.LocalIPPort=val;
        end
        function set.RemoteIPAddress(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RemoteIPAddress),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.UDPReceiver');
            obj.RemoteIPAddress=val;
        end
        function set.ReceiveBufferSize(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ReceiveBufferSize),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.UDPReceiver');
            obj.ReceiveBufferSize=val;
        end
        function set.MaximumMessageLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaximumMessageLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.UDPReceiver');
            obj.MaximumMessageLength=val;
        end
        function set.MessageDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MessageDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.UDPReceiver');
            obj.MessageDataType=val;
        end
        function set.IsMessageComplex(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.IsMessageComplex),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.UDPReceiver');
            obj.IsMessageComplex=val;
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
        function releaseImpl(obj)
            release(obj.cSFunObject);
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
        function y=isDoneImpl(obj)
            y=isDone(obj.cSFunObject);
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
            result='dsp.UDPReceiver';
        end
    end
end
