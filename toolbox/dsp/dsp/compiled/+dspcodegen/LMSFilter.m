classdef LMSFilter<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Method
Length
StepSizeSource
InitialConditions
WeightsResetCondition
RoundingMethod
OverflowAction
StepSizeDataType
CustomStepSizeDataType
LeakageFactorDataType
CustomLeakageFactorDataType
WeightsDataType
CustomWeightsDataType
EnergyProductDataType
CustomEnergyProductDataType
EnergyAccumulatorDataType
CustomEnergyAccumulatorDataType
ConvolutionProductDataType
CustomConvolutionProductDataType
ConvolutionAccumulatorDataType
CustomConvolutionAccumulatorDataType
StepSizeErrorProductDataType
CustomStepSizeErrorProductDataType
WeightsUpdateProductDataType
CustomWeightsUpdateProductDataType
QuotientDataType
CustomQuotientDataType
AdaptInputPort
WeightsResetInputPort
WeightsOutput
WeightsOutputPort
    end
    properties
StepSize
LeakageFactor
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=LMSFilter(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.LMSFilter.propListManager');
            coder.extrinsic('dspcodegen.LMSFilter.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.LMSFilter(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Length');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=dspcodegen.LMSFilter.propListManager(numValueOnlyProps,'Length');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.LMSFilter.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'Method',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'Method'));
                obj.Method=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'Length',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'Length'));
                obj.Length=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'StepSizeSource',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'StepSizeSource'));
                obj.StepSizeSource=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'InitialConditions',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'InitialConditions'));
                obj.InitialConditions=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'WeightsResetCondition',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'WeightsResetCondition'));
                obj.WeightsResetCondition=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'StepSizeDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'StepSizeDataType'));
                obj.StepSizeDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'CustomStepSizeDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'CustomStepSizeDataType'));
                obj.CustomStepSizeDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'LeakageFactorDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'LeakageFactorDataType'));
                obj.LeakageFactorDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'CustomLeakageFactorDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'CustomLeakageFactorDataType'));
                obj.CustomLeakageFactorDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'WeightsDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'WeightsDataType'));
                obj.WeightsDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'CustomWeightsDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'CustomWeightsDataType'));
                obj.CustomWeightsDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'EnergyProductDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'EnergyProductDataType'));
                obj.EnergyProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'CustomEnergyProductDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'CustomEnergyProductDataType'));
                obj.CustomEnergyProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'EnergyAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'EnergyAccumulatorDataType'));
                obj.EnergyAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'CustomEnergyAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'CustomEnergyAccumulatorDataType'));
                obj.CustomEnergyAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'ConvolutionProductDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'ConvolutionProductDataType'));
                obj.ConvolutionProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'CustomConvolutionProductDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'CustomConvolutionProductDataType'));
                obj.CustomConvolutionProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'ConvolutionAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'ConvolutionAccumulatorDataType'));
                obj.ConvolutionAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'CustomConvolutionAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'CustomConvolutionAccumulatorDataType'));
                obj.CustomConvolutionAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'StepSizeErrorProductDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'StepSizeErrorProductDataType'));
                obj.StepSizeErrorProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'CustomStepSizeErrorProductDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'CustomStepSizeErrorProductDataType'));
                obj.CustomStepSizeErrorProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'WeightsUpdateProductDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'WeightsUpdateProductDataType'));
                obj.WeightsUpdateProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'CustomWeightsUpdateProductDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'CustomWeightsUpdateProductDataType'));
                obj.CustomWeightsUpdateProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'QuotientDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'QuotientDataType'));
                obj.QuotientDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'CustomQuotientDataType',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'CustomQuotientDataType'));
                obj.CustomQuotientDataType=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'AdaptInputPort',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'AdaptInputPort'));
                obj.AdaptInputPort=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'WeightsResetInputPort',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'WeightsResetInputPort'));
                obj.WeightsResetInputPort=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'WeightsOutput',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'WeightsOutput'));
                obj.WeightsOutput=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'StepSize',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'StepSize'));
                obj.StepSize=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'LeakageFactor',false))
                val=coder.internal.const(dspcodegen.LMSFilter.getFieldFromMxStruct(propValues,'LeakageFactor'));
                obj.LeakageFactor=val;
            end
            if~coder.internal.const(dspcodegen.LMSFilter.propListManager(s,'WeightsOutputPort',false))
                val=coder.internal.const(get(obj.cSFunObject,'WeightsOutputPort'));
                obj.WeightsOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.StepSize(obj,val)
            coder.inline('always');
            noTuningError=true;
            if coder.internal.const(~coder.target('Rtw'))
                noTuningError=obj.NoTuningBeforeLockingCodeGenError;
            end
            setSfunSystemObject(obj.cSFunObject,'StepSize',val,noTuningError);%#ok<MCSUP>
            obj.StepSize=val;
        end
        function set.LeakageFactor(obj,val)
            coder.inline('always');
            noTuningError=true;
            if coder.internal.const(~coder.target('Rtw'))
                noTuningError=obj.NoTuningBeforeLockingCodeGenError;
            end
            setSfunSystemObject(obj.cSFunObject,'LeakageFactor',val,noTuningError);%#ok<MCSUP>
            obj.LeakageFactor=val;
        end
        function set.Method(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Method),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.Method=val;
        end
        function set.Length(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Length),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.Length=val;
        end
        function set.StepSizeSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.StepSizeSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.StepSizeSource=val;
        end
        function set.InitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.InitialConditions=val;
        end
        function set.WeightsResetCondition(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.WeightsResetCondition),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.WeightsResetCondition=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.OverflowAction=val;
        end
        function set.StepSizeDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.StepSizeDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.StepSizeDataType=val;
        end
        function set.CustomStepSizeDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomStepSizeDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.CustomStepSizeDataType=val;
        end
        function set.LeakageFactorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.LeakageFactorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.LeakageFactorDataType=val;
        end
        function set.CustomLeakageFactorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomLeakageFactorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.CustomLeakageFactorDataType=val;
        end
        function set.WeightsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.WeightsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.WeightsDataType=val;
        end
        function set.CustomWeightsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomWeightsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.CustomWeightsDataType=val;
        end
        function set.EnergyProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.EnergyProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.EnergyProductDataType=val;
        end
        function set.CustomEnergyProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomEnergyProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.CustomEnergyProductDataType=val;
        end
        function set.EnergyAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.EnergyAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.EnergyAccumulatorDataType=val;
        end
        function set.CustomEnergyAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomEnergyAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.CustomEnergyAccumulatorDataType=val;
        end
        function set.ConvolutionProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ConvolutionProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.ConvolutionProductDataType=val;
        end
        function set.CustomConvolutionProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomConvolutionProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.CustomConvolutionProductDataType=val;
        end
        function set.ConvolutionAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ConvolutionAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.ConvolutionAccumulatorDataType=val;
        end
        function set.CustomConvolutionAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomConvolutionAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.CustomConvolutionAccumulatorDataType=val;
        end
        function set.StepSizeErrorProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.StepSizeErrorProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.StepSizeErrorProductDataType=val;
        end
        function set.CustomStepSizeErrorProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomStepSizeErrorProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.CustomStepSizeErrorProductDataType=val;
        end
        function set.WeightsUpdateProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.WeightsUpdateProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.WeightsUpdateProductDataType=val;
        end
        function set.CustomWeightsUpdateProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomWeightsUpdateProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.CustomWeightsUpdateProductDataType=val;
        end
        function set.QuotientDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.QuotientDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.QuotientDataType=val;
        end
        function set.CustomQuotientDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomQuotientDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.CustomQuotientDataType=val;
        end
        function set.AdaptInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AdaptInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.AdaptInputPort=val;
        end
        function set.WeightsResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.WeightsResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.WeightsResetInputPort=val;
        end
        function set.WeightsOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.WeightsOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LMSFilter');
            obj.WeightsOutput=val;
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
            result='dsp.LMSFilter';
        end
    end
end
