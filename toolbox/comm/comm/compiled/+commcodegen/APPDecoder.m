classdef APPDecoder<matlab.System
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
Algorithm
NumScalingBits
CodedBitLLROutputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=APPDecoder(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.APPDecoder.propListManager');
            coder.extrinsic('commcodegen.APPDecoder.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.APPDecoder(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'TrellisStructure');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.APPDecoder.propListManager(numValueOnlyProps,'TrellisStructure');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.APPDecoder.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.APPDecoder.propListManager(s,'TrellisStructure',false))
                val=coder.internal.const(commcodegen.APPDecoder.getFieldFromMxStruct(propValues,'TrellisStructure'));
                obj.TrellisStructure=val;
            end
            if~coder.internal.const(commcodegen.APPDecoder.propListManager(s,'TerminationMethod',false))
                val=coder.internal.const(commcodegen.APPDecoder.getFieldFromMxStruct(propValues,'TerminationMethod'));
                obj.TerminationMethod=val;
            end
            if~coder.internal.const(commcodegen.APPDecoder.propListManager(s,'Algorithm',false))
                val=coder.internal.const(commcodegen.APPDecoder.getFieldFromMxStruct(propValues,'Algorithm'));
                obj.Algorithm=val;
            end
            if~coder.internal.const(commcodegen.APPDecoder.propListManager(s,'NumScalingBits',false))
                val=coder.internal.const(commcodegen.APPDecoder.getFieldFromMxStruct(propValues,'NumScalingBits'));
                obj.NumScalingBits=val;
            end
            if~coder.internal.const(commcodegen.APPDecoder.propListManager(s,'CodedBitLLROutputPort',false))
                val=coder.internal.const(commcodegen.APPDecoder.getFieldFromMxStruct(propValues,'CodedBitLLROutputPort'));
                obj.CodedBitLLROutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.TrellisStructure(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TrellisStructure),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.APPDecoder');
            obj.TrellisStructure=val;
        end
        function set.TerminationMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TerminationMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.APPDecoder');
            obj.TerminationMethod=val;
        end
        function set.Algorithm(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Algorithm),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.APPDecoder');
            obj.Algorithm=val;
        end
        function set.NumScalingBits(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumScalingBits),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.APPDecoder');
            obj.NumScalingBits=val;
        end
        function set.CodedBitLLROutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CodedBitLLROutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.APPDecoder');
            obj.CodedBitLLROutputPort=val;
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
            result='comm.APPDecoder';
        end
    end
end
