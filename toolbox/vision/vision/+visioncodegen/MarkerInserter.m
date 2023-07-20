classdef MarkerInserter<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Shape
BorderColorSource
BorderColor
CustomBorderColor
FillColorSource
FillColor
CustomFillColor
RoundingMethod
OverflowAction
OpacityDataType
CustomOpacityDataType
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
Fill
ROIInputPort
Antialiasing
useFltptMath4IntImage
    end
    properties
Size
Opacity
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=MarkerInserter(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.MarkerInserter.propListManager');
            coder.extrinsic('visioncodegen.MarkerInserter.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.MarkerInserter(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=visioncodegen.MarkerInserter.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.MarkerInserter.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'Shape',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'Shape'));
                obj.Shape=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'BorderColorSource',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'BorderColorSource'));
                obj.BorderColorSource=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'BorderColor',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'BorderColor'));
                obj.BorderColor=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'CustomBorderColor',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'CustomBorderColor'));
                obj.CustomBorderColor=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'FillColorSource',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'FillColorSource'));
                obj.FillColorSource=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'FillColor',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'FillColor'));
                obj.FillColor=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'CustomFillColor',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'CustomFillColor'));
                obj.CustomFillColor=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'OpacityDataType',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'OpacityDataType'));
                obj.OpacityDataType=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'CustomOpacityDataType',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'CustomOpacityDataType'));
                obj.CustomOpacityDataType=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'Fill',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'Fill'));
                obj.Fill=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'ROIInputPort',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'ROIInputPort'));
                obj.ROIInputPort=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'Antialiasing',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'Antialiasing'));
                obj.Antialiasing=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'Size',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'Size'));
                obj.Size=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'Opacity',false))
                val=coder.internal.const(visioncodegen.MarkerInserter.getFieldFromMxStruct(propValues,'Opacity'));
                obj.Opacity=val;
            end
            if~coder.internal.const(visioncodegen.MarkerInserter.propListManager(s,'useFltptMath4IntImage',false))
                val=coder.internal.const(get(obj.cSFunObject,'useFltptMath4IntImage'));
                obj.useFltptMath4IntImage=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Size(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Size',val,noTuningError);%#ok<MCSUP>
            obj.Size=val;
        end
        function set.Opacity(obj,val)
            coder.inline('always');
            noTuningError=true;
            if coder.internal.const(~coder.target('Rtw'))
                noTuningError=obj.NoTuningBeforeLockingCodeGenError;
            end
            setSfunSystemObject(obj.cSFunObject,'Opacity',val,noTuningError);%#ok<MCSUP>
            obj.Opacity=val;
        end
        function set.Shape(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Shape),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.Shape=val;
        end
        function set.BorderColorSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BorderColorSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.BorderColorSource=val;
        end
        function set.BorderColor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BorderColor),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.BorderColor=val;
        end
        function set.CustomBorderColor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomBorderColor),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.CustomBorderColor=val;
        end
        function set.FillColorSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FillColorSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.FillColorSource=val;
        end
        function set.FillColor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FillColor),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.FillColor=val;
        end
        function set.CustomFillColor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomFillColor),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.CustomFillColor=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.OverflowAction=val;
        end
        function set.OpacityDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OpacityDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.OpacityDataType=val;
        end
        function set.CustomOpacityDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOpacityDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.CustomOpacityDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.CustomAccumulatorDataType=val;
        end
        function set.Fill(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Fill),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.Fill=val;
        end
        function set.ROIInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ROIInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.ROIInputPort=val;
        end
        function set.Antialiasing(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Antialiasing),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.MarkerInserter');
            obj.Antialiasing=val;
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
            result='vision.MarkerInserter';
        end
    end
end
