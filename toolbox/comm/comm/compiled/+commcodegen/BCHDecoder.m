classdef BCHDecoder<matlab.System
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
ShortMessageLengthSource
PrimitivePolynomialSource
PrimitivePolynomial
GeneratorPolynomialSource
GeneratorPolynomial
PuncturePatternSource
PuncturePattern
ShortMessageLength
CheckGeneratorPolynomial
ErasuresInputPort
NumCorrectedErrorsOutputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=BCHDecoder(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.BCHDecoder.propListManager');
            coder.extrinsic('commcodegen.BCHDecoder.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.BCHDecoder(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'CodewordLength','MessageLength','GeneratorPolynomial','ShortMessageLength');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.BCHDecoder.propListManager(numValueOnlyProps,'CodewordLength','MessageLength','GeneratorPolynomial','ShortMessageLength');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.BCHDecoder.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'CodewordLength',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'CodewordLength'));
                obj.CodewordLength=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'MessageLength',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'MessageLength'));
                obj.MessageLength=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'ShortMessageLengthSource',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'ShortMessageLengthSource'));
                obj.ShortMessageLengthSource=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'PrimitivePolynomialSource',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'PrimitivePolynomialSource'));
                obj.PrimitivePolynomialSource=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'PrimitivePolynomial',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'PrimitivePolynomial'));
                obj.PrimitivePolynomial=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'GeneratorPolynomialSource',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'GeneratorPolynomialSource'));
                obj.GeneratorPolynomialSource=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'GeneratorPolynomial',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'GeneratorPolynomial'));
                obj.GeneratorPolynomial=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'PuncturePatternSource',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'PuncturePatternSource'));
                obj.PuncturePatternSource=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'PuncturePattern',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'PuncturePattern'));
                obj.PuncturePattern=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'ShortMessageLength',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'ShortMessageLength'));
                obj.ShortMessageLength=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'CheckGeneratorPolynomial',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'CheckGeneratorPolynomial'));
                obj.CheckGeneratorPolynomial=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'ErasuresInputPort',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'ErasuresInputPort'));
                obj.ErasuresInputPort=val;
            end
            if~coder.internal.const(commcodegen.BCHDecoder.propListManager(s,'NumCorrectedErrorsOutputPort',false))
                val=coder.internal.const(commcodegen.BCHDecoder.getFieldFromMxStruct(propValues,'NumCorrectedErrorsOutputPort'));
                obj.NumCorrectedErrorsOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.CodewordLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CodewordLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.CodewordLength=val;
        end
        function set.MessageLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MessageLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.MessageLength=val;
        end
        function set.ShortMessageLengthSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ShortMessageLengthSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.ShortMessageLengthSource=val;
        end
        function set.PrimitivePolynomialSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PrimitivePolynomialSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.PrimitivePolynomialSource=val;
        end
        function set.PrimitivePolynomial(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PrimitivePolynomial),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.PrimitivePolynomial=val;
        end
        function set.GeneratorPolynomialSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.GeneratorPolynomialSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.GeneratorPolynomialSource=val;
        end
        function set.GeneratorPolynomial(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.GeneratorPolynomial),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.GeneratorPolynomial=val;
        end
        function set.PuncturePatternSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PuncturePatternSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.PuncturePatternSource=val;
        end
        function set.PuncturePattern(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PuncturePattern),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.PuncturePattern=val;
        end
        function set.ShortMessageLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ShortMessageLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.ShortMessageLength=val;
        end
        function set.CheckGeneratorPolynomial(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CheckGeneratorPolynomial),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.CheckGeneratorPolynomial=val;
        end
        function set.ErasuresInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ErasuresInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.ErasuresInputPort=val;
        end
        function set.NumCorrectedErrorsOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumCorrectedErrorsOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BCHDecoder');
            obj.NumCorrectedErrorsOutputPort=val;
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
            result='comm.BCHDecoder';
        end
    end
end
