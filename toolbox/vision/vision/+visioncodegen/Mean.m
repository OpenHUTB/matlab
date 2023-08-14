classdef Mean<matlab.System
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
AccumulatorDataType
CustomAccumulatorDataType
OutputDataType
CustomOutputDataType
RunningMean
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
        function obj=Mean(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.Mean.propListManager');
            coder.extrinsic('visioncodegen.Mean.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.Mean(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=visioncodegen.Mean.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.Mean.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'Dimension',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'Dimension'));
                obj.Dimension=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'ResetCondition',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'ResetCondition'));
                obj.ResetCondition=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'CustomDimension',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'CustomDimension'));
                obj.CustomDimension=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'ROIForm',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'ROIForm'));
                obj.ROIForm=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'ROIPortion',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'ROIPortion'));
                obj.ROIPortion=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'ROIStatistics',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'ROIStatistics'));
                obj.ROIStatistics=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'RunningMean',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'RunningMean'));
                obj.RunningMean=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'ROIProcessing',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'ROIProcessing'));
                obj.ROIProcessing=val;
            end
            if~coder.internal.const(visioncodegen.Mean.propListManager(s,'ValidityOutputPort',false))
                val=coder.internal.const(visioncodegen.Mean.getFieldFromMxStruct(propValues,'ValidityOutputPort'));
                obj.ValidityOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Dimension(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Dimension),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.Dimension=val;
        end
        function set.ResetCondition(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetCondition),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.ResetCondition=val;
        end
        function set.CustomDimension(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDimension),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.CustomDimension=val;
        end
        function set.ROIForm(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIForm),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.ROIForm=val;
        end
        function set.ROIPortion(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIPortion),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.ROIPortion=val;
        end
        function set.ROIStatistics(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIStatistics),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.ROIStatistics=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.OverflowAction=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.CustomOutputDataType=val;
        end
        function set.RunningMean(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RunningMean),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.RunningMean=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.ResetInputPort=val;
        end
        function set.ROIProcessing(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIProcessing),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
            obj.ROIProcessing=val;
        end
        function set.ValidityOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ValidityOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.Mean');
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
            result='vision.Mean';
        end
    end
end
