classdef FIRInterpolator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
InterpolationFactor
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
FullPrecisionOverride
Numerator
RateOptions
EnableMultiChannelParallelism
CoderTarget
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=FIRInterpolator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.FIRInterpolator.propListManager');
            coder.extrinsic('dspcodegen.FIRInterpolator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.FIRInterpolator(varargin{:},'CoderTarget',coder.target);
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'InterpolationFactor','Numerator','NumeratorSource','DesignMethod');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=dspcodegen.FIRInterpolator.propListManager(numValueOnlyProps,'InterpolationFactor','Numerator','NumeratorSource','DesignMethod');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.FIRInterpolator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'InterpolationFactor',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'InterpolationFactor'));
                obj.InterpolationFactor=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'NumeratorSource',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'NumeratorSource'));
                obj.NumeratorSource=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'DesignMethod',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'DesignMethod'));
                obj.DesignMethod=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'CoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'CoefficientsDataType'));
                obj.CoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'CustomCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'CustomCoefficientsDataType'));
                obj.CustomCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'FullPrecisionOverride',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'FullPrecisionOverride'));
                obj.FullPrecisionOverride=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'Numerator',false))
                val=coder.internal.const(dspcodegen.FIRInterpolator.getFieldFromMxStruct(propValues,'Numerator'));
                obj.Numerator=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'RateOptions',false))
                val=coder.internal.const(get(obj.cSFunObject,'RateOptions'));
                obj.RateOptions=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'EnableMultiChannelParallelism',false))
                val=coder.internal.const(get(obj.cSFunObject,'EnableMultiChannelParallelism'));
                obj.EnableMultiChannelParallelism=val;
            end
            if~coder.internal.const(dspcodegen.FIRInterpolator.propListManager(s,'CoderTarget',false))
                val=coder.internal.const(get(obj.cSFunObject,'CoderTarget'));
                obj.CoderTarget=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.InterpolationFactor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InterpolationFactor),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.InterpolationFactor=val;
        end
        function set.NumeratorSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.NumeratorSource=val;
        end
        function set.DesignMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DesignMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.DesignMethod=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.OverflowAction=val;
        end
        function set.CoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.CoefficientsDataType=val;
        end
        function set.CustomCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.CustomCoefficientsDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.CustomOutputDataType=val;
        end
        function set.FullPrecisionOverride(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FullPrecisionOverride),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
            obj.FullPrecisionOverride=val;
        end
        function set.Numerator(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Numerator),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRInterpolator');
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
            result='dsp.FIRInterpolator';
        end
    end
end
