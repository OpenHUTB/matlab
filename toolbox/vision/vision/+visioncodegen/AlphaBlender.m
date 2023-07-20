classdef AlphaBlender<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Operation
OpacitySource
MaskSource
LocationSource
RoundingMethod
OverflowAction
OpacityDataType
CustomOpacityDataType
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
OutputDataType
CustomOutputDataType
    end
    properties
Opacity
Mask
Location
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=AlphaBlender(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.AlphaBlender.propListManager');
            coder.extrinsic('visioncodegen.AlphaBlender.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.AlphaBlender(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=visioncodegen.AlphaBlender.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.AlphaBlender.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'Operation',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'Operation'));
                obj.Operation=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'OpacitySource',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'OpacitySource'));
                obj.OpacitySource=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'MaskSource',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'MaskSource'));
                obj.MaskSource=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'LocationSource',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'LocationSource'));
                obj.LocationSource=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'OpacityDataType',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'OpacityDataType'));
                obj.OpacityDataType=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'CustomOpacityDataType',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'CustomOpacityDataType'));
                obj.CustomOpacityDataType=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'Opacity',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'Opacity'));
                obj.Opacity=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'Mask',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'Mask'));
                obj.Mask=val;
            end
            if~coder.internal.const(visioncodegen.AlphaBlender.propListManager(s,'Location',false))
                val=coder.internal.const(visioncodegen.AlphaBlender.getFieldFromMxStruct(propValues,'Location'));
                obj.Location=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
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
        function set.Mask(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Mask',val,noTuningError);%#ok<MCSUP>
            obj.Mask=val;
        end
        function set.Location(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Location',val,noTuningError);%#ok<MCSUP>
            obj.Location=val;
        end
        function set.Operation(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Operation),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.Operation=val;
        end
        function set.OpacitySource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OpacitySource),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.OpacitySource=val;
        end
        function set.MaskSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaskSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.MaskSource=val;
        end
        function set.LocationSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.LocationSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.LocationSource=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.OverflowAction=val;
        end
        function set.OpacityDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OpacityDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.OpacityDataType=val;
        end
        function set.CustomOpacityDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOpacityDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.CustomOpacityDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.AlphaBlender');
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
            result='vision.AlphaBlender';
        end
    end
end
