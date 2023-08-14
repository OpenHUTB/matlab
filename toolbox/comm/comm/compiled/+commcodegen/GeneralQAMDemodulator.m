classdef GeneralQAMDemodulator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Variance
BitOutput
Constellation
DecisionMethod
VarianceSource
OutputDataType
RoundingMethod
OverflowAction
ConstellationDataType
CustomConstellationDataType
Accumulator1DataType
CustomAccumulator1DataType
ProductInputDataType
CustomProductInputDataType
ProductOutputDataType
CustomProductOutputDataType
Accumulator2DataType
CustomAccumulator2DataType
Accumulator3DataType
CustomAccumulator3DataType
NoiseScalingInputDataType
CustomNoiseScalingInputDataType
InverseVarianceDataType
CustomInverseVarianceDataType
CustomOutputDataType
FullPrecisionOverride
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=GeneralQAMDemodulator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.GeneralQAMDemodulator.propListManager');
            coder.extrinsic('commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.GeneralQAMDemodulator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Constellation');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.GeneralQAMDemodulator.propListManager(numValueOnlyProps,'Constellation');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.GeneralQAMDemodulator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'Variance',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'Variance'));
                obj.Variance=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'BitOutput',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'BitOutput'));
                obj.BitOutput=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'Constellation',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'Constellation'));
                obj.Constellation=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'DecisionMethod',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'DecisionMethod'));
                obj.DecisionMethod=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'VarianceSource',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'VarianceSource'));
                obj.VarianceSource=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'ConstellationDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'ConstellationDataType'));
                obj.ConstellationDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'CustomConstellationDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'CustomConstellationDataType'));
                obj.CustomConstellationDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'Accumulator1DataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'Accumulator1DataType'));
                obj.Accumulator1DataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'CustomAccumulator1DataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'CustomAccumulator1DataType'));
                obj.CustomAccumulator1DataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'ProductInputDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'ProductInputDataType'));
                obj.ProductInputDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'CustomProductInputDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'CustomProductInputDataType'));
                obj.CustomProductInputDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'ProductOutputDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'ProductOutputDataType'));
                obj.ProductOutputDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'CustomProductOutputDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'CustomProductOutputDataType'));
                obj.CustomProductOutputDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'Accumulator2DataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'Accumulator2DataType'));
                obj.Accumulator2DataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'CustomAccumulator2DataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'CustomAccumulator2DataType'));
                obj.CustomAccumulator2DataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'Accumulator3DataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'Accumulator3DataType'));
                obj.Accumulator3DataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'CustomAccumulator3DataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'CustomAccumulator3DataType'));
                obj.CustomAccumulator3DataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'NoiseScalingInputDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'NoiseScalingInputDataType'));
                obj.NoiseScalingInputDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'CustomNoiseScalingInputDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'CustomNoiseScalingInputDataType'));
                obj.CustomNoiseScalingInputDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'InverseVarianceDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'InverseVarianceDataType'));
                obj.InverseVarianceDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'CustomInverseVarianceDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'CustomInverseVarianceDataType'));
                obj.CustomInverseVarianceDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(commcodegen.GeneralQAMDemodulator.propListManager(s,'FullPrecisionOverride',false))
                val=coder.internal.const(commcodegen.GeneralQAMDemodulator.getFieldFromMxStruct(propValues,'FullPrecisionOverride'));
                obj.FullPrecisionOverride=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Variance(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Variance),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.Variance=val;
        end
        function set.BitOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BitOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.BitOutput=val;
        end
        function set.Constellation(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Constellation),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.Constellation=val;
        end
        function set.DecisionMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DecisionMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.DecisionMethod=val;
        end
        function set.VarianceSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VarianceSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.VarianceSource=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.OutputDataType=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.OverflowAction=val;
        end
        function set.ConstellationDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ConstellationDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.ConstellationDataType=val;
        end
        function set.CustomConstellationDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomConstellationDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.CustomConstellationDataType=val;
        end
        function set.Accumulator1DataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Accumulator1DataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.Accumulator1DataType=val;
        end
        function set.CustomAccumulator1DataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulator1DataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.CustomAccumulator1DataType=val;
        end
        function set.ProductInputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductInputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.ProductInputDataType=val;
        end
        function set.CustomProductInputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductInputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.CustomProductInputDataType=val;
        end
        function set.ProductOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.ProductOutputDataType=val;
        end
        function set.CustomProductOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.CustomProductOutputDataType=val;
        end
        function set.Accumulator2DataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Accumulator2DataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.Accumulator2DataType=val;
        end
        function set.CustomAccumulator2DataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulator2DataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.CustomAccumulator2DataType=val;
        end
        function set.Accumulator3DataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Accumulator3DataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.Accumulator3DataType=val;
        end
        function set.CustomAccumulator3DataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulator3DataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.CustomAccumulator3DataType=val;
        end
        function set.NoiseScalingInputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NoiseScalingInputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.NoiseScalingInputDataType=val;
        end
        function set.CustomNoiseScalingInputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomNoiseScalingInputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.CustomNoiseScalingInputDataType=val;
        end
        function set.InverseVarianceDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InverseVarianceDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.InverseVarianceDataType=val;
        end
        function set.CustomInverseVarianceDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomInverseVarianceDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.CustomInverseVarianceDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.CustomOutputDataType=val;
        end
        function set.FullPrecisionOverride(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FullPrecisionOverride),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GeneralQAMDemodulator');
            obj.FullPrecisionOverride=val;
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
            result='comm.GeneralQAMDemodulator';
        end
    end
end
