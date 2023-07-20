classdef TemplateMatcher<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Metric
OutputValue
SearchMethod
NeighborhoodSize
RoundingMethod
OverflowAction
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
OutputDataType
CustomOutputDataType
BestMatchNeighborhoodOutputPort
ROIInputPort
ROIValidityOutputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=TemplateMatcher(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.TemplateMatcher.propListManager');
            coder.extrinsic('visioncodegen.TemplateMatcher.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.TemplateMatcher(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=visioncodegen.TemplateMatcher.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.TemplateMatcher.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'Metric',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'Metric'));
                obj.Metric=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'OutputValue',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'OutputValue'));
                obj.OutputValue=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'SearchMethod',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'SearchMethod'));
                obj.SearchMethod=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'NeighborhoodSize',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'NeighborhoodSize'));
                obj.NeighborhoodSize=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'BestMatchNeighborhoodOutputPort',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'BestMatchNeighborhoodOutputPort'));
                obj.BestMatchNeighborhoodOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'ROIInputPort',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'ROIInputPort'));
                obj.ROIInputPort=val;
            end
            if~coder.internal.const(visioncodegen.TemplateMatcher.propListManager(s,'ROIValidityOutputPort',false))
                val=coder.internal.const(visioncodegen.TemplateMatcher.getFieldFromMxStruct(propValues,'ROIValidityOutputPort'));
                obj.ROIValidityOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Metric(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Metric),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.Metric=val;
        end
        function set.OutputValue(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputValue),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.OutputValue=val;
        end
        function set.SearchMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SearchMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.SearchMethod=val;
        end
        function set.NeighborhoodSize(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NeighborhoodSize),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.NeighborhoodSize=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.OverflowAction=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.CustomOutputDataType=val;
        end
        function set.BestMatchNeighborhoodOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BestMatchNeighborhoodOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.BestMatchNeighborhoodOutputPort=val;
        end
        function set.ROIInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.ROIInputPort=val;
        end
        function set.ROIValidityOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIValidityOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.TemplateMatcher');
            obj.ROIValidityOutputPort=val;
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
            result='vision.TemplateMatcher';
        end
    end
end
