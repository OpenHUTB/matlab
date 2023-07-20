classdef VectorQuantizerEncoder<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
CodebookSource
DistortionMeasure
WeightsSource
TiebreakerRule
OutputIndexDataType
RoundingMethod
OverflowAction
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
CodewordOutputPort
QuantizationErrorOutputPort
    end
    properties
Codebook
Weights
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=VectorQuantizerEncoder(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.VectorQuantizerEncoder.propListManager');
            coder.extrinsic('dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.VectorQuantizerEncoder(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.VectorQuantizerEncoder.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.VectorQuantizerEncoder.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'CodebookSource',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'CodebookSource'));
                obj.CodebookSource=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'DistortionMeasure',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'DistortionMeasure'));
                obj.DistortionMeasure=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'WeightsSource',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'WeightsSource'));
                obj.WeightsSource=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'TiebreakerRule',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'TiebreakerRule'));
                obj.TiebreakerRule=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'OutputIndexDataType',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'OutputIndexDataType'));
                obj.OutputIndexDataType=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'CodewordOutputPort',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'CodewordOutputPort'));
                obj.CodewordOutputPort=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'QuantizationErrorOutputPort',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'QuantizationErrorOutputPort'));
                obj.QuantizationErrorOutputPort=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'Codebook',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'Codebook'));
                obj.Codebook=val;
            end
            if~coder.internal.const(dspcodegen.VectorQuantizerEncoder.propListManager(s,'Weights',false))
                val=coder.internal.const(dspcodegen.VectorQuantizerEncoder.getFieldFromMxStruct(propValues,'Weights'));
                obj.Weights=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Codebook(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Codebook',val,noTuningError);%#ok<MCSUP>
            obj.Codebook=val;
        end
        function set.Weights(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Weights',val,noTuningError);%#ok<MCSUP>
            obj.Weights=val;
        end
        function set.CodebookSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CodebookSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.CodebookSource=val;
        end
        function set.DistortionMeasure(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DistortionMeasure),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.DistortionMeasure=val;
        end
        function set.WeightsSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.WeightsSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.WeightsSource=val;
        end
        function set.TiebreakerRule(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TiebreakerRule),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.TiebreakerRule=val;
        end
        function set.OutputIndexDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputIndexDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.OutputIndexDataType=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.OverflowAction=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.CustomAccumulatorDataType=val;
        end
        function set.CodewordOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CodewordOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.CodewordOutputPort=val;
        end
        function set.QuantizationErrorOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.QuantizationErrorOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VectorQuantizerEncoder');
            obj.QuantizationErrorOutputPort=val;
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
            result='dsp.VectorQuantizerEncoder';
        end
    end
end
