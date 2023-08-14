classdef RectangularQAMDemodulator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
DecisionMethod
VarianceSource
ModulationOrder
PhaseOffset
SymbolMapping
CustomSymbolMapping
NormalizationMethod
MinimumDistance
AveragePower
PeakPower
DerotateFactorDataType
CustomDerotateFactorDataType
DenormalizationFactorDataType
CustomDenormalizationFactorDataType
ProductDataType
CustomProductDataType
ProductRoundingMethod
ProductOverflowAction
SumDataType
CustomSumDataType
BitOutput
FullPrecisionOverride
OutputDataType
    end
    properties
Variance
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=RectangularQAMDemodulator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.RectangularQAMDemodulator.propListManager');
            coder.extrinsic('commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.RectangularQAMDemodulator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'ModulationOrder');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.RectangularQAMDemodulator.propListManager(numValueOnlyProps,'ModulationOrder');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.RectangularQAMDemodulator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'DecisionMethod',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'DecisionMethod'));
                obj.DecisionMethod=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'VarianceSource',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'VarianceSource'));
                obj.VarianceSource=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'ModulationOrder',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'ModulationOrder'));
                obj.ModulationOrder=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'PhaseOffset',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'PhaseOffset'));
                obj.PhaseOffset=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'SymbolMapping',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'SymbolMapping'));
                obj.SymbolMapping=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'CustomSymbolMapping',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'CustomSymbolMapping'));
                obj.CustomSymbolMapping=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'NormalizationMethod',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'NormalizationMethod'));
                obj.NormalizationMethod=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'MinimumDistance',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'MinimumDistance'));
                obj.MinimumDistance=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'AveragePower',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'AveragePower'));
                obj.AveragePower=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'PeakPower',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'PeakPower'));
                obj.PeakPower=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'DerotateFactorDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'DerotateFactorDataType'));
                obj.DerotateFactorDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'CustomDerotateFactorDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'CustomDerotateFactorDataType'));
                obj.CustomDerotateFactorDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'DenormalizationFactorDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'DenormalizationFactorDataType'));
                obj.DenormalizationFactorDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'CustomDenormalizationFactorDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'CustomDenormalizationFactorDataType'));
                obj.CustomDenormalizationFactorDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'ProductRoundingMethod',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'ProductRoundingMethod'));
                obj.ProductRoundingMethod=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'ProductOverflowAction',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'ProductOverflowAction'));
                obj.ProductOverflowAction=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'SumDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'SumDataType'));
                obj.SumDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'CustomSumDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'CustomSumDataType'));
                obj.CustomSumDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'BitOutput',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'BitOutput'));
                obj.BitOutput=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'FullPrecisionOverride',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'FullPrecisionOverride'));
                obj.FullPrecisionOverride=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMDemodulator.propListManager(s,'Variance',false))
                val=coder.internal.const(commcodegen.RectangularQAMDemodulator.getFieldFromMxStruct(propValues,'Variance'));
                obj.Variance=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Variance(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Variance',val,noTuningError);%#ok<MCSUP>
            obj.Variance=val;
        end
        function set.DecisionMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DecisionMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.DecisionMethod=val;
        end
        function set.VarianceSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VarianceSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.VarianceSource=val;
        end
        function set.ModulationOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ModulationOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.ModulationOrder=val;
        end
        function set.PhaseOffset(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseOffset),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.PhaseOffset=val;
        end
        function set.SymbolMapping(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SymbolMapping),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.SymbolMapping=val;
        end
        function set.CustomSymbolMapping(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomSymbolMapping),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.CustomSymbolMapping=val;
        end
        function set.NormalizationMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NormalizationMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.NormalizationMethod=val;
        end
        function set.MinimumDistance(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MinimumDistance),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.MinimumDistance=val;
        end
        function set.AveragePower(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AveragePower),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.AveragePower=val;
        end
        function set.PeakPower(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PeakPower),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.PeakPower=val;
        end
        function set.DerotateFactorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DerotateFactorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.DerotateFactorDataType=val;
        end
        function set.CustomDerotateFactorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDerotateFactorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.CustomDerotateFactorDataType=val;
        end
        function set.DenormalizationFactorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenormalizationFactorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.DenormalizationFactorDataType=val;
        end
        function set.CustomDenormalizationFactorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDenormalizationFactorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.CustomDenormalizationFactorDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.CustomProductDataType=val;
        end
        function set.ProductRoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductRoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.ProductRoundingMethod=val;
        end
        function set.ProductOverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductOverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.ProductOverflowAction=val;
        end
        function set.SumDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SumDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.SumDataType=val;
        end
        function set.CustomSumDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomSumDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.CustomSumDataType=val;
        end
        function set.BitOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BitOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.BitOutput=val;
        end
        function set.FullPrecisionOverride(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FullPrecisionOverride),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.FullPrecisionOverride=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMDemodulator');
            obj.OutputDataType=val;
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
            result='comm.RectangularQAMDemodulator';
        end
    end
end
