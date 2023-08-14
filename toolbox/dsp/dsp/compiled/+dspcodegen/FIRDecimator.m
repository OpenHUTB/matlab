classdef FIRDecimator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
DecimationFactor
NumeratorSource
Structure
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
AllowArbitraryInputLength
Numerator
DecimationOffset
RateOptions
CoderTarget
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=FIRDecimator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.FIRDecimator.propListManager');
            coder.extrinsic('dspcodegen.FIRDecimator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.FIRDecimator(varargin{:},'CoderTarget',coder.target);
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'DecimationFactor','Numerator','NumeratorSource');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=dspcodegen.FIRDecimator.propListManager(numValueOnlyProps,'DecimationFactor','Numerator','NumeratorSource');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.FIRDecimator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'DecimationFactor',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'DecimationFactor'));
                obj.DecimationFactor=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'NumeratorSource',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'NumeratorSource'));
                obj.NumeratorSource=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'Structure',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'Structure'));
                obj.Structure=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'CoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'CoefficientsDataType'));
                obj.CoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'CustomCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'CustomCoefficientsDataType'));
                obj.CustomCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'FullPrecisionOverride',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'FullPrecisionOverride'));
                obj.FullPrecisionOverride=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'AllowArbitraryInputLength',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'AllowArbitraryInputLength'));
                obj.AllowArbitraryInputLength=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'Numerator',false))
                val=coder.internal.const(dspcodegen.FIRDecimator.getFieldFromMxStruct(propValues,'Numerator'));
                obj.Numerator=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'DecimationOffset',false))
                val=coder.internal.const(get(obj.cSFunObject,'DecimationOffset'));
                obj.DecimationOffset=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'RateOptions',false))
                val=coder.internal.const(get(obj.cSFunObject,'RateOptions'));
                obj.RateOptions=val;
            end
            if~coder.internal.const(dspcodegen.FIRDecimator.propListManager(s,'CoderTarget',false))
                val=coder.internal.const(get(obj.cSFunObject,'CoderTarget'));
                obj.CoderTarget=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.DecimationFactor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DecimationFactor),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.DecimationFactor=val;
        end
        function set.NumeratorSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.NumeratorSource=val;
        end
        function set.Structure(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Structure),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.Structure=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.OverflowAction=val;
        end
        function set.CoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.CoefficientsDataType=val;
        end
        function set.CustomCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.CustomCoefficientsDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.CustomOutputDataType=val;
        end
        function set.FullPrecisionOverride(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FullPrecisionOverride),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.FullPrecisionOverride=val;
        end
        function set.AllowArbitraryInputLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AllowArbitraryInputLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
            obj.AllowArbitraryInputLength=val;
        end
        function set.Numerator(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Numerator),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRDecimator');
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
            result='dsp.FIRDecimator';
        end
    end
end
