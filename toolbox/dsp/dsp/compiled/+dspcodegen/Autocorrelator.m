classdef Autocorrelator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
MaximumLagSource
MaximumLag
Scaling
Method
RoundingMethod
OverflowAction
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
OutputDataType
CustomOutputDataType
FullPrecisionOverride
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=Autocorrelator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.Autocorrelator.propListManager');
            coder.extrinsic('dspcodegen.Autocorrelator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.Autocorrelator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.Autocorrelator.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.Autocorrelator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'MaximumLagSource',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'MaximumLagSource'));
                obj.MaximumLagSource=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'MaximumLag',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'MaximumLag'));
                obj.MaximumLag=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'Scaling',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'Scaling'));
                obj.Scaling=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'Method',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'Method'));
                obj.Method=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.Autocorrelator.propListManager(s,'FullPrecisionOverride',false))
                val=coder.internal.const(dspcodegen.Autocorrelator.getFieldFromMxStruct(propValues,'FullPrecisionOverride'));
                obj.FullPrecisionOverride=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.MaximumLagSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaximumLagSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.MaximumLagSource=val;
        end
        function set.MaximumLag(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaximumLag),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.MaximumLag=val;
        end
        function set.Scaling(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Scaling),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.Scaling=val;
        end
        function set.Method(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Method),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.Method=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.OverflowAction=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.CustomOutputDataType=val;
        end
        function set.FullPrecisionOverride(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FullPrecisionOverride),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Autocorrelator');
            obj.FullPrecisionOverride=val;
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
            result='dsp.Autocorrelator';
        end
    end
end
