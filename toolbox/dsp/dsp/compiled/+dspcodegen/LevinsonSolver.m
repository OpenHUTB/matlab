classdef LevinsonSolver<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
ZerothLagZeroAction
RoundingMethod
OverflowAction
ACoefficientDataType
CustomACoefficientDataType
KCoefficientDataType
CustomKCoefficientDataType
PredictionErrorDataType
CustomPredictionErrorDataType
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
AOutputPort
KOutputPort
PredictionErrorOutputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=LevinsonSolver(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.LevinsonSolver.propListManager');
            coder.extrinsic('dspcodegen.LevinsonSolver.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.LevinsonSolver(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.LevinsonSolver.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.LevinsonSolver.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'ZerothLagZeroAction',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'ZerothLagZeroAction'));
                obj.ZerothLagZeroAction=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'ACoefficientDataType',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'ACoefficientDataType'));
                obj.ACoefficientDataType=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'CustomACoefficientDataType',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'CustomACoefficientDataType'));
                obj.CustomACoefficientDataType=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'KCoefficientDataType',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'KCoefficientDataType'));
                obj.KCoefficientDataType=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'CustomKCoefficientDataType',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'CustomKCoefficientDataType'));
                obj.CustomKCoefficientDataType=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'PredictionErrorDataType',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'PredictionErrorDataType'));
                obj.PredictionErrorDataType=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'CustomPredictionErrorDataType',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'CustomPredictionErrorDataType'));
                obj.CustomPredictionErrorDataType=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'AOutputPort',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'AOutputPort'));
                obj.AOutputPort=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'KOutputPort',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'KOutputPort'));
                obj.KOutputPort=val;
            end
            if~coder.internal.const(dspcodegen.LevinsonSolver.propListManager(s,'PredictionErrorOutputPort',false))
                val=coder.internal.const(dspcodegen.LevinsonSolver.getFieldFromMxStruct(propValues,'PredictionErrorOutputPort'));
                obj.PredictionErrorOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.ZerothLagZeroAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ZerothLagZeroAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.ZerothLagZeroAction=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.OverflowAction=val;
        end
        function set.ACoefficientDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ACoefficientDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.ACoefficientDataType=val;
        end
        function set.CustomACoefficientDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomACoefficientDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.CustomACoefficientDataType=val;
        end
        function set.KCoefficientDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.KCoefficientDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.KCoefficientDataType=val;
        end
        function set.CustomKCoefficientDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomKCoefficientDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.CustomKCoefficientDataType=val;
        end
        function set.PredictionErrorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PredictionErrorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.PredictionErrorDataType=val;
        end
        function set.CustomPredictionErrorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomPredictionErrorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.CustomPredictionErrorDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.CustomAccumulatorDataType=val;
        end
        function set.AOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.AOutputPort=val;
        end
        function set.KOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.KOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.KOutputPort=val;
        end
        function set.PredictionErrorOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PredictionErrorOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.LevinsonSolver');
            obj.PredictionErrorOutputPort=val;
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
            result='dsp.LevinsonSolver';
        end
    end
end
