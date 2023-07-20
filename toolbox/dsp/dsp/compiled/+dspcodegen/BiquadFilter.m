classdef BiquadFilter<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Structure
SOSMatrixSource
SOSMatrix
ScaleValues
InitialConditions
NumeratorInitialConditions
DenominatorInitialConditions
RoundingMethod
OverflowAction
MultiplicandDataType
CustomMultiplicandDataType
SectionInputDataType
CustomSectionInputDataType
SectionOutputDataType
CustomSectionOutputDataType
NumeratorCoefficientsDataType
CustomNumeratorCoefficientsDataType
OptimizeUnityScaleValues
ScaleValuesInputPort
DenominatorCoefficientsDataType
CustomDenominatorCoefficientsDataType
ScaleValuesDataType
CustomScaleValuesDataType
NumeratorProductDataType
CustomNumeratorProductDataType
DenominatorProductDataType
CustomDenominatorProductDataType
NumeratorAccumulatorDataType
CustomNumeratorAccumulatorDataType
DenominatorAccumulatorDataType
CustomDenominatorAccumulatorDataType
StateDataType
CustomStateDataType
NumeratorStateDataType
CustomNumeratorStateDataType
DenominatorStateDataType
CustomDenominatorStateDataType
OutputDataType
CustomOutputDataType
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=BiquadFilter(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.BiquadFilter.propListManager');
            coder.extrinsic('dspcodegen.BiquadFilter.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.BiquadFilter(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.BiquadFilter.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.BiquadFilter.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'Structure',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'Structure'));
                obj.Structure=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'SOSMatrixSource',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'SOSMatrixSource'));
                obj.SOSMatrixSource=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'SOSMatrix',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'SOSMatrix'));
                obj.SOSMatrix=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'ScaleValues',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'ScaleValues'));
                obj.ScaleValues=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'InitialConditions',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'InitialConditions'));
                obj.InitialConditions=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'NumeratorInitialConditions',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'NumeratorInitialConditions'));
                obj.NumeratorInitialConditions=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'DenominatorInitialConditions',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'DenominatorInitialConditions'));
                obj.DenominatorInitialConditions=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'MultiplicandDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'MultiplicandDataType'));
                obj.MultiplicandDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomMultiplicandDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomMultiplicandDataType'));
                obj.CustomMultiplicandDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'SectionInputDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'SectionInputDataType'));
                obj.SectionInputDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomSectionInputDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomSectionInputDataType'));
                obj.CustomSectionInputDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'SectionOutputDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'SectionOutputDataType'));
                obj.SectionOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomSectionOutputDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomSectionOutputDataType'));
                obj.CustomSectionOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'NumeratorCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'NumeratorCoefficientsDataType'));
                obj.NumeratorCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomNumeratorCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomNumeratorCoefficientsDataType'));
                obj.CustomNumeratorCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'OptimizeUnityScaleValues',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'OptimizeUnityScaleValues'));
                obj.OptimizeUnityScaleValues=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'ScaleValuesInputPort',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'ScaleValuesInputPort'));
                obj.ScaleValuesInputPort=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'DenominatorCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'DenominatorCoefficientsDataType'));
                obj.DenominatorCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomDenominatorCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomDenominatorCoefficientsDataType'));
                obj.CustomDenominatorCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'ScaleValuesDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'ScaleValuesDataType'));
                obj.ScaleValuesDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomScaleValuesDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomScaleValuesDataType'));
                obj.CustomScaleValuesDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'NumeratorProductDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'NumeratorProductDataType'));
                obj.NumeratorProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomNumeratorProductDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomNumeratorProductDataType'));
                obj.CustomNumeratorProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'DenominatorProductDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'DenominatorProductDataType'));
                obj.DenominatorProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomDenominatorProductDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomDenominatorProductDataType'));
                obj.CustomDenominatorProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'NumeratorAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'NumeratorAccumulatorDataType'));
                obj.NumeratorAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomNumeratorAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomNumeratorAccumulatorDataType'));
                obj.CustomNumeratorAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'DenominatorAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'DenominatorAccumulatorDataType'));
                obj.DenominatorAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomDenominatorAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomDenominatorAccumulatorDataType'));
                obj.CustomDenominatorAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'StateDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'StateDataType'));
                obj.StateDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomStateDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomStateDataType'));
                obj.CustomStateDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'NumeratorStateDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'NumeratorStateDataType'));
                obj.NumeratorStateDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomNumeratorStateDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomNumeratorStateDataType'));
                obj.CustomNumeratorStateDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'DenominatorStateDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'DenominatorStateDataType'));
                obj.DenominatorStateDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomDenominatorStateDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomDenominatorStateDataType'));
                obj.CustomDenominatorStateDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.BiquadFilter.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.BiquadFilter.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Structure(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Structure),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.Structure=val;
        end
        function set.SOSMatrixSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SOSMatrixSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.SOSMatrixSource=val;
        end
        function set.SOSMatrix(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SOSMatrix),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.SOSMatrix=val;
        end
        function set.ScaleValues(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ScaleValues),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.ScaleValues=val;
        end
        function set.InitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.InitialConditions=val;
        end
        function set.NumeratorInitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorInitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.NumeratorInitialConditions=val;
        end
        function set.DenominatorInitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorInitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.DenominatorInitialConditions=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.OverflowAction=val;
        end
        function set.MultiplicandDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MultiplicandDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.MultiplicandDataType=val;
        end
        function set.CustomMultiplicandDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomMultiplicandDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomMultiplicandDataType=val;
        end
        function set.SectionInputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SectionInputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.SectionInputDataType=val;
        end
        function set.CustomSectionInputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomSectionInputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomSectionInputDataType=val;
        end
        function set.SectionOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SectionOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.SectionOutputDataType=val;
        end
        function set.CustomSectionOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomSectionOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomSectionOutputDataType=val;
        end
        function set.NumeratorCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.NumeratorCoefficientsDataType=val;
        end
        function set.CustomNumeratorCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomNumeratorCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomNumeratorCoefficientsDataType=val;
        end
        function set.OptimizeUnityScaleValues(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OptimizeUnityScaleValues),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.OptimizeUnityScaleValues=val;
        end
        function set.ScaleValuesInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ScaleValuesInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.ScaleValuesInputPort=val;
        end
        function set.DenominatorCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.DenominatorCoefficientsDataType=val;
        end
        function set.CustomDenominatorCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDenominatorCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomDenominatorCoefficientsDataType=val;
        end
        function set.ScaleValuesDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ScaleValuesDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.ScaleValuesDataType=val;
        end
        function set.CustomScaleValuesDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomScaleValuesDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomScaleValuesDataType=val;
        end
        function set.NumeratorProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.NumeratorProductDataType=val;
        end
        function set.CustomNumeratorProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomNumeratorProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomNumeratorProductDataType=val;
        end
        function set.DenominatorProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.DenominatorProductDataType=val;
        end
        function set.CustomDenominatorProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDenominatorProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomDenominatorProductDataType=val;
        end
        function set.NumeratorAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.NumeratorAccumulatorDataType=val;
        end
        function set.CustomNumeratorAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomNumeratorAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomNumeratorAccumulatorDataType=val;
        end
        function set.DenominatorAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.DenominatorAccumulatorDataType=val;
        end
        function set.CustomDenominatorAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDenominatorAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomDenominatorAccumulatorDataType=val;
        end
        function set.StateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.StateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.StateDataType=val;
        end
        function set.CustomStateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomStateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomStateDataType=val;
        end
        function set.NumeratorStateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorStateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.NumeratorStateDataType=val;
        end
        function set.CustomNumeratorStateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomNumeratorStateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomNumeratorStateDataType=val;
        end
        function set.DenominatorStateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorStateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.DenominatorStateDataType=val;
        end
        function set.CustomDenominatorStateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDenominatorStateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.CustomDenominatorStateDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.BiquadFilter');
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
            result='dsp.BiquadFilter';
        end
    end
end
