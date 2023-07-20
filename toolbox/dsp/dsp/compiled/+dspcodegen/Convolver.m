classdef Convolver<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
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
        function obj=Convolver(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.Convolver.propListManager');
            coder.extrinsic('dspcodegen.Convolver.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.Convolver(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.Convolver.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.Convolver.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.Convolver.propListManager(s,'Method',false))
                val=coder.internal.const(dspcodegen.Convolver.getFieldFromMxStruct(propValues,'Method'));
                obj.Method=val;
            end
            if~coder.internal.const(dspcodegen.Convolver.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.Convolver.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.Convolver.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.Convolver.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.Convolver.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.Convolver.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.Convolver.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.Convolver.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.Convolver.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.Convolver.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.Convolver.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.Convolver.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.Convolver.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.Convolver.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.Convolver.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.Convolver.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.Convolver.propListManager(s,'FullPrecisionOverride',false))
                val=coder.internal.const(dspcodegen.Convolver.getFieldFromMxStruct(propValues,'FullPrecisionOverride'));
                obj.FullPrecisionOverride=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Method(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Method),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Convolver');
            obj.Method=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Convolver');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Convolver');
            obj.OverflowAction=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Convolver');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Convolver');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Convolver');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Convolver');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Convolver');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Convolver');
            obj.CustomOutputDataType=val;
        end
        function set.FullPrecisionOverride(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FullPrecisionOverride),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Convolver');
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
            result='dsp.Convolver';
        end
    end
end
