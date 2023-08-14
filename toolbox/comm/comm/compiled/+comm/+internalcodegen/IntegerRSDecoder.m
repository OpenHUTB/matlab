classdef IntegerRSDecoder<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
CodewordLength
MessageLength
PuncturePatternSourceIndex
PuncturePattern
DecoderParameters
ErasuresInputPort
NumCorrectedErrorsOutputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=IntegerRSDecoder(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('comm.internalcodegen.IntegerRSDecoder.propListManager');
            coder.extrinsic('comm.internalcodegen.IntegerRSDecoder.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.internal.IntegerRSDecoder(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=comm.internalcodegen.IntegerRSDecoder.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=comm.internalcodegen.IntegerRSDecoder.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(comm.internalcodegen.IntegerRSDecoder.propListManager(s,'CodewordLength',false))
                val=coder.internal.const(get(obj.cSFunObject,'CodewordLength'));
                obj.CodewordLength=val;
            end
            if~coder.internal.const(comm.internalcodegen.IntegerRSDecoder.propListManager(s,'MessageLength',false))
                val=coder.internal.const(get(obj.cSFunObject,'MessageLength'));
                obj.MessageLength=val;
            end
            if~coder.internal.const(comm.internalcodegen.IntegerRSDecoder.propListManager(s,'PuncturePatternSourceIndex',false))
                val=coder.internal.const(get(obj.cSFunObject,'PuncturePatternSourceIndex'));
                obj.PuncturePatternSourceIndex=val;
            end
            if~coder.internal.const(comm.internalcodegen.IntegerRSDecoder.propListManager(s,'PuncturePattern',false))
                val=coder.internal.const(get(obj.cSFunObject,'PuncturePattern'));
                obj.PuncturePattern=val;
            end
            if~coder.internal.const(comm.internalcodegen.IntegerRSDecoder.propListManager(s,'DecoderParameters',false))
                val=coder.internal.const(get(obj.cSFunObject,'DecoderParameters'));
                obj.DecoderParameters=val;
            end
            if~coder.internal.const(comm.internalcodegen.IntegerRSDecoder.propListManager(s,'ErasuresInputPort',false))
                val=coder.internal.const(get(obj.cSFunObject,'ErasuresInputPort'));
                obj.ErasuresInputPort=val;
            end
            if~coder.internal.const(comm.internalcodegen.IntegerRSDecoder.propListManager(s,'NumCorrectedErrorsOutputPort',false))
                val=coder.internal.const(get(obj.cSFunObject,'NumCorrectedErrorsOutputPort'));
                obj.NumCorrectedErrorsOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
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
            result='comm.internal.IntegerRSDecoder';
        end
    end
end
