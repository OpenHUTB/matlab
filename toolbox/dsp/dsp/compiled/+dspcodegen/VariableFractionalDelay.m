classdef VariableFractionalDelay<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
InterpolationMethod
FilterHalfLength
FilterLength
InterpolationPointsPerSample
Bandwidth
InitialConditions
MaximumDelay
FIRSmallDelayAction
FarrowSmallDelayAction
RoundingMethod
OverflowAction
CoefficientsDataType
CustomCoefficientsDataType
ProductPolynomialValueDataType
CustomProductPolynomialValueDataType
AccumulatorPolynomialValueDataType
CustomAccumulatorPolynomialValueDataType
MultiplicandPolynomialValueDataType
CustomMultiplicandPolynomialValueDataType
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
OutputDataType
CustomOutputDataType
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=VariableFractionalDelay(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.VariableFractionalDelay.propListManager');
            coder.extrinsic('dspcodegen.VariableFractionalDelay.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.VariableFractionalDelay(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.VariableFractionalDelay.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.VariableFractionalDelay.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'InterpolationMethod',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'InterpolationMethod'));
                obj.InterpolationMethod=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'FilterHalfLength',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'FilterHalfLength'));
                obj.FilterHalfLength=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'FilterLength',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'FilterLength'));
                obj.FilterLength=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'InterpolationPointsPerSample',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'InterpolationPointsPerSample'));
                obj.InterpolationPointsPerSample=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'Bandwidth',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'Bandwidth'));
                obj.Bandwidth=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'InitialConditions',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'InitialConditions'));
                obj.InitialConditions=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'MaximumDelay',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'MaximumDelay'));
                obj.MaximumDelay=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'FIRSmallDelayAction',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'FIRSmallDelayAction'));
                obj.FIRSmallDelayAction=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'FarrowSmallDelayAction',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'FarrowSmallDelayAction'));
                obj.FarrowSmallDelayAction=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'CoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'CoefficientsDataType'));
                obj.CoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'CustomCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'CustomCoefficientsDataType'));
                obj.CustomCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'ProductPolynomialValueDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'ProductPolynomialValueDataType'));
                obj.ProductPolynomialValueDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'CustomProductPolynomialValueDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'CustomProductPolynomialValueDataType'));
                obj.CustomProductPolynomialValueDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'AccumulatorPolynomialValueDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'AccumulatorPolynomialValueDataType'));
                obj.AccumulatorPolynomialValueDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'CustomAccumulatorPolynomialValueDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'CustomAccumulatorPolynomialValueDataType'));
                obj.CustomAccumulatorPolynomialValueDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'MultiplicandPolynomialValueDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'MultiplicandPolynomialValueDataType'));
                obj.MultiplicandPolynomialValueDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'CustomMultiplicandPolynomialValueDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'CustomMultiplicandPolynomialValueDataType'));
                obj.CustomMultiplicandPolynomialValueDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.VariableFractionalDelay.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.VariableFractionalDelay.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.InterpolationMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InterpolationMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.InterpolationMethod=val;
        end
        function set.FilterHalfLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FilterHalfLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.FilterHalfLength=val;
        end
        function set.FilterLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FilterLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.FilterLength=val;
        end
        function set.InterpolationPointsPerSample(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InterpolationPointsPerSample),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.InterpolationPointsPerSample=val;
        end
        function set.Bandwidth(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Bandwidth),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.Bandwidth=val;
        end
        function set.InitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.InitialConditions=val;
        end
        function set.MaximumDelay(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaximumDelay),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.MaximumDelay=val;
        end
        function set.FIRSmallDelayAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FIRSmallDelayAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.FIRSmallDelayAction=val;
        end
        function set.FarrowSmallDelayAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FarrowSmallDelayAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.FarrowSmallDelayAction=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.OverflowAction=val;
        end
        function set.CoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.CoefficientsDataType=val;
        end
        function set.CustomCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.CustomCoefficientsDataType=val;
        end
        function set.ProductPolynomialValueDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductPolynomialValueDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.ProductPolynomialValueDataType=val;
        end
        function set.CustomProductPolynomialValueDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductPolynomialValueDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.CustomProductPolynomialValueDataType=val;
        end
        function set.AccumulatorPolynomialValueDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorPolynomialValueDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.AccumulatorPolynomialValueDataType=val;
        end
        function set.CustomAccumulatorPolynomialValueDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorPolynomialValueDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.CustomAccumulatorPolynomialValueDataType=val;
        end
        function set.MultiplicandPolynomialValueDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MultiplicandPolynomialValueDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.MultiplicandPolynomialValueDataType=val;
        end
        function set.CustomMultiplicandPolynomialValueDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomMultiplicandPolynomialValueDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.CustomMultiplicandPolynomialValueDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.VariableFractionalDelay');
            obj.CustomOutputDataType=val;
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
            result='dsp.VariableFractionalDelay';
        end
    end
end
