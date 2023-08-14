classdef PNSequence<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Polynomial
InitialConditionsSource
InitialConditions
MaskSource
Mask
MaximumOutputSize
SamplesPerFrame
NumPackedBits
OutputDataType
VariableSizeOutput
ResetInputPort
BitPackedOutput
SignedOutput
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=PNSequence(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.PNSequence.propListManager');
            coder.extrinsic('commcodegen.PNSequence.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.PNSequence(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=commcodegen.PNSequence.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.PNSequence.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'Polynomial',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'Polynomial'));
                obj.Polynomial=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'InitialConditionsSource',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'InitialConditionsSource'));
                obj.InitialConditionsSource=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'InitialConditions',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'InitialConditions'));
                obj.InitialConditions=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'MaskSource',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'MaskSource'));
                obj.MaskSource=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'Mask',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'Mask'));
                obj.Mask=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'MaximumOutputSize',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'MaximumOutputSize'));
                obj.MaximumOutputSize=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'SamplesPerFrame',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'SamplesPerFrame'));
                obj.SamplesPerFrame=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'NumPackedBits',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'NumPackedBits'));
                obj.NumPackedBits=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'VariableSizeOutput',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'VariableSizeOutput'));
                obj.VariableSizeOutput=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'BitPackedOutput',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'BitPackedOutput'));
                obj.BitPackedOutput=val;
            end
            if~coder.internal.const(commcodegen.PNSequence.propListManager(s,'SignedOutput',false))
                val=coder.internal.const(commcodegen.PNSequence.getFieldFromMxStruct(propValues,'SignedOutput'));
                obj.SignedOutput=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Polynomial(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Polynomial),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.Polynomial=val;
        end
        function set.InitialConditionsSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditionsSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.InitialConditionsSource=val;
        end
        function set.InitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.InitialConditions=val;
        end
        function set.MaskSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaskSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.MaskSource=val;
        end
        function set.Mask(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Mask),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.Mask=val;
        end
        function set.MaximumOutputSize(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaximumOutputSize),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.MaximumOutputSize=val;
        end
        function set.SamplesPerFrame(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerFrame),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.SamplesPerFrame=val;
        end
        function set.NumPackedBits(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumPackedBits),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.NumPackedBits=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.OutputDataType=val;
        end
        function set.VariableSizeOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VariableSizeOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.VariableSizeOutput=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.ResetInputPort=val;
        end
        function set.BitPackedOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BitPackedOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.BitPackedOutput=val;
        end
        function set.SignedOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SignedOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PNSequence');
            obj.SignedOutput=val;
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
            result='comm.PNSequence';
        end
    end
end
