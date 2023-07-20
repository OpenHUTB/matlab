classdef UDPSender<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
RemoteIPAddress
LocalIPPortSource
LocalIPPort
SendBufferSize
SendAtExit
LengthInputPort
    end
    properties
RemoteIPPort
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=UDPSender(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.UDPSender.propListManager');
            coder.extrinsic('dspcodegen.UDPSender.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.UDPSender(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.UDPSender.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.UDPSender.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.UDPSender.propListManager(s,'RemoteIPAddress',false))
                val=coder.internal.const(dspcodegen.UDPSender.getFieldFromMxStruct(propValues,'RemoteIPAddress'));
                obj.RemoteIPAddress=val;
            end
            if~coder.internal.const(dspcodegen.UDPSender.propListManager(s,'LocalIPPortSource',false))
                val=coder.internal.const(dspcodegen.UDPSender.getFieldFromMxStruct(propValues,'LocalIPPortSource'));
                obj.LocalIPPortSource=val;
            end
            if~coder.internal.const(dspcodegen.UDPSender.propListManager(s,'LocalIPPort',false))
                val=coder.internal.const(dspcodegen.UDPSender.getFieldFromMxStruct(propValues,'LocalIPPort'));
                obj.LocalIPPort=val;
            end
            if~coder.internal.const(dspcodegen.UDPSender.propListManager(s,'SendBufferSize',false))
                val=coder.internal.const(dspcodegen.UDPSender.getFieldFromMxStruct(propValues,'SendBufferSize'));
                obj.SendBufferSize=val;
            end
            if~coder.internal.const(dspcodegen.UDPSender.propListManager(s,'RemoteIPPort',false))
                val=coder.internal.const(dspcodegen.UDPSender.getFieldFromMxStruct(propValues,'RemoteIPPort'));
                obj.RemoteIPPort=val;
            end
            if~coder.internal.const(dspcodegen.UDPSender.propListManager(s,'SendAtExit',false))
                val=coder.internal.const(get(obj.cSFunObject,'SendAtExit'));
                obj.SendAtExit=val;
            end
            if~coder.internal.const(dspcodegen.UDPSender.propListManager(s,'LengthInputPort',false))
                val=coder.internal.const(get(obj.cSFunObject,'LengthInputPort'));
                obj.LengthInputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.RemoteIPPort(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'RemoteIPPort',val,noTuningError);%#ok<MCSUP>
            obj.RemoteIPPort=val;
        end
        function set.RemoteIPAddress(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RemoteIPAddress),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.UDPSender');
            obj.RemoteIPAddress=val;
        end
        function set.LocalIPPortSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.LocalIPPortSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.UDPSender');
            obj.LocalIPPortSource=val;
        end
        function set.LocalIPPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.LocalIPPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.UDPSender');
            obj.LocalIPPort=val;
        end
        function set.SendBufferSize(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SendBufferSize),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.UDPSender');
            obj.SendBufferSize=val;
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
            result='dsp.UDPSender';
        end
    end
end
