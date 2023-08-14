classdef CumulativeProduct<matlab.System
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
RoundingMethod
OverflowAction
IntermediateProductDataType
CustomIntermediateProductDataType
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
OutputDataType
CustomOutputDataType
ResetInputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=CumulativeProduct(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.CumulativeProduct.propListManager');
            coder.extrinsic('dspcodegen.CumulativeProduct.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.CumulativeProduct(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.CumulativeProduct.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.CumulativeProduct.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'Dimension',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'Dimension'));
                obj.Dimension=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'ResetCondition',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'ResetCondition'));
                obj.ResetCondition=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'IntermediateProductDataType',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'IntermediateProductDataType'));
                obj.IntermediateProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'CustomIntermediateProductDataType',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'CustomIntermediateProductDataType'));
                obj.CustomIntermediateProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.CumulativeProduct.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(dspcodegen.CumulativeProduct.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Dimension(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Dimension),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.Dimension=val;
        end
        function set.ResetCondition(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetCondition),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.ResetCondition=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.OverflowAction=val;
        end
        function set.IntermediateProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.IntermediateProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.IntermediateProductDataType=val;
        end
        function set.CustomIntermediateProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomIntermediateProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.CustomIntermediateProductDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.CustomOutputDataType=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.CumulativeProduct');
            obj.ResetInputPort=val;
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
            result='dsp.CumulativeProduct';
        end
    end
end
