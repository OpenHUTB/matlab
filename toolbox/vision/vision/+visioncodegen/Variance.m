classdef Variance<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Dimension
ResetCondition
CustomDimension
ROIForm
ROIPortion
ROIStatistics
RoundingMethod
OverflowAction
InputSquaredProductDataType
CustomInputSquaredProductDataType
InputSumSquaredProductDataType
CustomInputSumSquaredProductDataType
AccumulatorDataType
CustomAccumulatorDataType
OutputDataType
CustomOutputDataType
RunningVariance
ResetInputPort
ROIProcessing
ValidityOutputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=Variance(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.Variance.propListManager');
            coder.extrinsic('visioncodegen.Variance.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.Variance(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=visioncodegen.Variance.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.Variance.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'Dimension',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'Dimension'));
                obj.Dimension=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'ResetCondition',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'ResetCondition'));
                obj.ResetCondition=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'CustomDimension',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'CustomDimension'));
                obj.CustomDimension=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'ROIForm',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'ROIForm'));
                obj.ROIForm=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'ROIPortion',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'ROIPortion'));
                obj.ROIPortion=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'ROIStatistics',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'ROIStatistics'));
                obj.ROIStatistics=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'InputSquaredProductDataType',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'InputSquaredProductDataType'));
                obj.InputSquaredProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'CustomInputSquaredProductDataType',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'CustomInputSquaredProductDataType'));
                obj.CustomInputSquaredProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'InputSumSquaredProductDataType',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'InputSumSquaredProductDataType'));
                obj.InputSumSquaredProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'CustomInputSumSquaredProductDataType',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'CustomInputSumSquaredProductDataType'));
                obj.CustomInputSumSquaredProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'RunningVariance',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'RunningVariance'));
                obj.RunningVariance=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'ROIProcessing',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'ROIProcessing'));
                obj.ROIProcessing=val;
            end
            if~coder.internal.const(visioncodegen.Variance.propListManager(s,'ValidityOutputPort',false))
                val=coder.internal.const(visioncodegen.Variance.getFieldFromMxStruct(propValues,'ValidityOutputPort'));
                obj.ValidityOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Dimension(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Dimension),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.Dimension=val;
        end
        function set.ResetCondition(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetCondition),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.ResetCondition=val;
        end
        function set.CustomDimension(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDimension),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.CustomDimension=val;
        end
        function set.ROIForm(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIForm),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.ROIForm=val;
        end
        function set.ROIPortion(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIPortion),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.ROIPortion=val;
        end
        function set.ROIStatistics(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIStatistics),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.ROIStatistics=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.OverflowAction=val;
        end
        function set.InputSquaredProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InputSquaredProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.InputSquaredProductDataType=val;
        end
        function set.CustomInputSquaredProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomInputSquaredProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.CustomInputSquaredProductDataType=val;
        end
        function set.InputSumSquaredProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InputSumSquaredProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.InputSumSquaredProductDataType=val;
        end
        function set.CustomInputSumSquaredProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomInputSumSquaredProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.CustomInputSumSquaredProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.CustomOutputDataType=val;
        end
        function set.RunningVariance(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RunningVariance),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.RunningVariance=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.ResetInputPort=val;
        end
        function set.ROIProcessing(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIProcessing),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.ROIProcessing=val;
        end
        function set.ValidityOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ValidityOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Variance');
            obj.ValidityOutputPort=val;
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
            result='vision.Variance';
        end
    end
end
