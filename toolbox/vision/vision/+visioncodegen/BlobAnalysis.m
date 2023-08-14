classdef BlobAnalysis<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
OutputDataType
Connectivity
MaximumCount
RoundingMethod
OverflowAction
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
CentroidDataType
CustomCentroidDataType
EquivalentDiameterSquaredDataType
CustomEquivalentDiameterSquaredDataType
ExtentDataType
CustomExtentDataType
PerimeterDataType
CustomPerimeterDataType
AreaOutputPort
CentroidOutputPort
BoundingBoxOutputPort
MajorAxisLengthOutputPort
MinorAxisLengthOutputPort
OrientationOutputPort
EccentricityOutputPort
EquivalentDiameterSquaredOutputPort
ExtentOutputPort
PerimeterOutputPort
LabelMatrixOutputPort
ExcludeBorderBlobs
MinimumBlobAreaSource
MaximumBlobAreaSource
    end
    properties
MinimumBlobArea
MaximumBlobArea
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=BlobAnalysis(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.BlobAnalysis.propListManager');
            coder.extrinsic('visioncodegen.BlobAnalysis.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.BlobAnalysis(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=visioncodegen.BlobAnalysis.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.BlobAnalysis.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'Connectivity',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'Connectivity'));
                obj.Connectivity=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'MaximumCount',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'MaximumCount'));
                obj.MaximumCount=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'CentroidDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'CentroidDataType'));
                obj.CentroidDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'CustomCentroidDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'CustomCentroidDataType'));
                obj.CustomCentroidDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'EquivalentDiameterSquaredDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'EquivalentDiameterSquaredDataType'));
                obj.EquivalentDiameterSquaredDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'CustomEquivalentDiameterSquaredDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'CustomEquivalentDiameterSquaredDataType'));
                obj.CustomEquivalentDiameterSquaredDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'ExtentDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'ExtentDataType'));
                obj.ExtentDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'CustomExtentDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'CustomExtentDataType'));
                obj.CustomExtentDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'PerimeterDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'PerimeterDataType'));
                obj.PerimeterDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'CustomPerimeterDataType',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'CustomPerimeterDataType'));
                obj.CustomPerimeterDataType=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'AreaOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'AreaOutputPort'));
                obj.AreaOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'CentroidOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'CentroidOutputPort'));
                obj.CentroidOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'BoundingBoxOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'BoundingBoxOutputPort'));
                obj.BoundingBoxOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'MajorAxisLengthOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'MajorAxisLengthOutputPort'));
                obj.MajorAxisLengthOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'MinorAxisLengthOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'MinorAxisLengthOutputPort'));
                obj.MinorAxisLengthOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'OrientationOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'OrientationOutputPort'));
                obj.OrientationOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'EccentricityOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'EccentricityOutputPort'));
                obj.EccentricityOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'EquivalentDiameterSquaredOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'EquivalentDiameterSquaredOutputPort'));
                obj.EquivalentDiameterSquaredOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'ExtentOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'ExtentOutputPort'));
                obj.ExtentOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'PerimeterOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'PerimeterOutputPort'));
                obj.PerimeterOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'LabelMatrixOutputPort',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'LabelMatrixOutputPort'));
                obj.LabelMatrixOutputPort=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'ExcludeBorderBlobs',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'ExcludeBorderBlobs'));
                obj.ExcludeBorderBlobs=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'MinimumBlobArea',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'MinimumBlobArea'));
                obj.MinimumBlobArea=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'MaximumBlobArea',false))
                val=coder.internal.const(visioncodegen.BlobAnalysis.getFieldFromMxStruct(propValues,'MaximumBlobArea'));
                obj.MaximumBlobArea=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'MinimumBlobAreaSource',false))
                val=coder.internal.const(get(obj.cSFunObject,'MinimumBlobAreaSource'));
                obj.MinimumBlobAreaSource=val;
            end
            if~coder.internal.const(visioncodegen.BlobAnalysis.propListManager(s,'MaximumBlobAreaSource',false))
                val=coder.internal.const(get(obj.cSFunObject,'MaximumBlobAreaSource'));
                obj.MaximumBlobAreaSource=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.MinimumBlobArea(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'MinimumBlobArea',val,noTuningError);%#ok<MCSUP>
            obj.MinimumBlobArea=val;
        end
        function set.MaximumBlobArea(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'MaximumBlobArea',val,noTuningError);%#ok<MCSUP>
            obj.MaximumBlobArea=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.OutputDataType=val;
        end
        function set.Connectivity(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Connectivity),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.Connectivity=val;
        end
        function set.MaximumCount(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaximumCount),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.MaximumCount=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.OverflowAction=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.CustomAccumulatorDataType=val;
        end
        function set.CentroidDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CentroidDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.CentroidDataType=val;
        end
        function set.CustomCentroidDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomCentroidDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.CustomCentroidDataType=val;
        end
        function set.EquivalentDiameterSquaredDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.EquivalentDiameterSquaredDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.EquivalentDiameterSquaredDataType=val;
        end
        function set.CustomEquivalentDiameterSquaredDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomEquivalentDiameterSquaredDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.CustomEquivalentDiameterSquaredDataType=val;
        end
        function set.ExtentDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ExtentDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.ExtentDataType=val;
        end
        function set.CustomExtentDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomExtentDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.CustomExtentDataType=val;
        end
        function set.PerimeterDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PerimeterDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.PerimeterDataType=val;
        end
        function set.CustomPerimeterDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomPerimeterDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.CustomPerimeterDataType=val;
        end
        function set.AreaOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AreaOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.AreaOutputPort=val;
        end
        function set.CentroidOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CentroidOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.CentroidOutputPort=val;
        end
        function set.BoundingBoxOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BoundingBoxOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.BoundingBoxOutputPort=val;
        end
        function set.MajorAxisLengthOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MajorAxisLengthOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.MajorAxisLengthOutputPort=val;
        end
        function set.MinorAxisLengthOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MinorAxisLengthOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.MinorAxisLengthOutputPort=val;
        end
        function set.OrientationOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OrientationOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.OrientationOutputPort=val;
        end
        function set.EccentricityOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.EccentricityOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.EccentricityOutputPort=val;
        end
        function set.EquivalentDiameterSquaredOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.EquivalentDiameterSquaredOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.EquivalentDiameterSquaredOutputPort=val;
        end
        function set.ExtentOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ExtentOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.ExtentOutputPort=val;
        end
        function set.PerimeterOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PerimeterOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.PerimeterOutputPort=val;
        end
        function set.LabelMatrixOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.LabelMatrixOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.LabelMatrixOutputPort=val;
        end
        function set.ExcludeBorderBlobs(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ExcludeBorderBlobs),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BlobAnalysis');
            obj.ExcludeBorderBlobs=val;
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
            result='vision.BlobAnalysis';
        end
    end
end
