classdef GeometricShearer<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Direction
OutputSize
ValuesSource
Values
MaximumValue
InterpolationMethod
RoundingMethod
OverflowAction
ValuesDataType
CustomValuesDataType
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
OutputDataType
CustomOutputDataType
    end
    properties
BackgroundFillValue
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=GeometricShearer(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.GeometricShearer.propListManager');
            coder.extrinsic('visioncodegen.GeometricShearer.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.GeometricShearer(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=visioncodegen.GeometricShearer.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.GeometricShearer.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'Direction',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'Direction'));
                obj.Direction=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'OutputSize',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'OutputSize'));
                obj.OutputSize=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'ValuesSource',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'ValuesSource'));
                obj.ValuesSource=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'Values',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'Values'));
                obj.Values=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'MaximumValue',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'MaximumValue'));
                obj.MaximumValue=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'InterpolationMethod',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'InterpolationMethod'));
                obj.InterpolationMethod=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'ValuesDataType',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'ValuesDataType'));
                obj.ValuesDataType=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'CustomValuesDataType',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'CustomValuesDataType'));
                obj.CustomValuesDataType=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.GeometricShearer.propListManager(s,'BackgroundFillValue',false))
                val=coder.internal.const(visioncodegen.GeometricShearer.getFieldFromMxStruct(propValues,'BackgroundFillValue'));
                obj.BackgroundFillValue=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.BackgroundFillValue(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'BackgroundFillValue',val,noTuningError);%#ok<MCSUP>
            obj.BackgroundFillValue=val;
        end
        function set.Direction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Direction),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.Direction=val;
        end
        function set.OutputSize(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputSize),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.OutputSize=val;
        end
        function set.ValuesSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ValuesSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.ValuesSource=val;
        end
        function set.Values(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Values),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.Values=val;
        end
        function set.MaximumValue(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaximumValue),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.MaximumValue=val;
        end
        function set.InterpolationMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InterpolationMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.InterpolationMethod=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.OverflowAction=val;
        end
        function set.ValuesDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ValuesDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.ValuesDataType=val;
        end
        function set.CustomValuesDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomValuesDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.CustomValuesDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GeometricShearer');
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
            result='vision.GeometricShearer';
        end
    end
end
