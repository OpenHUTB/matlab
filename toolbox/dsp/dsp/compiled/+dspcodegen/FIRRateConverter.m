classdef FIRRateConverter<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
InterpolationFactor
DecimationFactor
NumeratorSource
DesignMethod
RoundingMethod
OverflowAction
CoefficientsDataType
CustomCoefficientsDataType
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
OutputDataType
CustomOutputDataType
AllowArbitraryInputLength
FullPrecisionOverride
Numerator
CoderTarget
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=FIRRateConverter(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.FIRRateConverter.propListManager');
            coder.extrinsic('dspcodegen.FIRRateConverter.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.FIRRateConverter(varargin{:},'CoderTarget',coder.target);
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'InterpolationFactor','DecimationFactor','Numerator');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=dspcodegen.FIRRateConverter.propListManager(numValueOnlyProps,'InterpolationFactor','DecimationFactor','Numerator');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.FIRRateConverter.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'InterpolationFactor',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'InterpolationFactor'));
                obj.InterpolationFactor=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'DecimationFactor',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'DecimationFactor'));
                obj.DecimationFactor=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'NumeratorSource',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'NumeratorSource'));
                obj.NumeratorSource=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'DesignMethod',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'DesignMethod'));
                obj.DesignMethod=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'CoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'CoefficientsDataType'));
                obj.CoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'CustomCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'CustomCoefficientsDataType'));
                obj.CustomCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'AllowArbitraryInputLength',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'AllowArbitraryInputLength'));
                obj.AllowArbitraryInputLength=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'FullPrecisionOverride',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'FullPrecisionOverride'));
                obj.FullPrecisionOverride=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'Numerator',false))
                val=coder.internal.const(dspcodegen.FIRRateConverter.getFieldFromMxStruct(propValues,'Numerator'));
                obj.Numerator=val;
            end
            if~coder.internal.const(dspcodegen.FIRRateConverter.propListManager(s,'CoderTarget',false))
                val=coder.internal.const(get(obj.cSFunObject,'CoderTarget'));
                obj.CoderTarget=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.InterpolationFactor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InterpolationFactor),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.InterpolationFactor=val;
        end
        function set.DecimationFactor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DecimationFactor),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.DecimationFactor=val;
        end
        function set.NumeratorSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.NumeratorSource=val;
        end
        function set.DesignMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DesignMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.DesignMethod=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.OverflowAction=val;
        end
        function set.CoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.CoefficientsDataType=val;
        end
        function set.CustomCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.CustomCoefficientsDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.CustomOutputDataType=val;
        end
        function set.AllowArbitraryInputLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AllowArbitraryInputLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.AllowArbitraryInputLength=val;
        end
        function set.FullPrecisionOverride(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FullPrecisionOverride),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.FullPrecisionOverride=val;
        end
        function set.Numerator(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Numerator),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRRateConverter');
            obj.Numerator=val;
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
            result='dsp.FIRRateConverter';
        end
    end
end
