classdef Minimum<matlab.System
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
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
ValueOutputPort
RunningMinimum
IndexOutputPort
ResetInputPort
ROIProcessing
ValidityOutputPort
IndexBase
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=Minimum(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.Minimum.propListManager');
            coder.extrinsic('visioncodegen.Minimum.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.Minimum(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=visioncodegen.Minimum.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.Minimum.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'Dimension',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'Dimension'));
                obj.Dimension=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'ResetCondition',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'ResetCondition'));
                obj.ResetCondition=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'CustomDimension',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'CustomDimension'));
                obj.CustomDimension=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'ROIForm',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'ROIForm'));
                obj.ROIForm=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'ROIPortion',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'ROIPortion'));
                obj.ROIPortion=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'ROIStatistics',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'ROIStatistics'));
                obj.ROIStatistics=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'ValueOutputPort',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'ValueOutputPort'));
                obj.ValueOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'RunningMinimum',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'RunningMinimum'));
                obj.RunningMinimum=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'IndexOutputPort',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'IndexOutputPort'));
                obj.IndexOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'ROIProcessing',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'ROIProcessing'));
                obj.ROIProcessing=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'ValidityOutputPort',false))
                val=coder.internal.const(visioncodegen.Minimum.getFieldFromMxStruct(propValues,'ValidityOutputPort'));
                obj.ValidityOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.Minimum.propListManager(s,'IndexBase',false))
                val=coder.internal.const(get(obj.cSFunObject,'IndexBase'));
                obj.IndexBase=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Dimension(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Dimension),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.Dimension=val;
        end
        function set.ResetCondition(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetCondition),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.ResetCondition=val;
        end
        function set.CustomDimension(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDimension),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.CustomDimension=val;
        end
        function set.ROIForm(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIForm),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.ROIForm=val;
        end
        function set.ROIPortion(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIPortion),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.ROIPortion=val;
        end
        function set.ROIStatistics(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIStatistics),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.ROIStatistics=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.OverflowAction=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.CustomAccumulatorDataType=val;
        end
        function set.ValueOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ValueOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.ValueOutputPort=val;
        end
        function set.RunningMinimum(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RunningMinimum),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.RunningMinimum=val;
        end
        function set.IndexOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.IndexOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.IndexOutputPort=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.ResetInputPort=val;
        end
        function set.ROIProcessing(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIProcessing),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
            obj.ROIProcessing=val;
        end
        function set.ValidityOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ValidityOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Minimum');
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
            result='vision.Minimum';
        end
    end
end
