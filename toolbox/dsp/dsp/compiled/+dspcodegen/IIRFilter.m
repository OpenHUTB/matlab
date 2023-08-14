classdef IIRFilter<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
InitialConditions
NumeratorInitialConditions
DenominatorInitialConditions
Structure
RoundingMethod
OverflowAction
StateDataType
CustomStateDataType
NumeratorCoefficientsDataType
CustomNumeratorCoefficientsDataType
DenominatorCoefficientsDataType
CustomDenominatorCoefficientsDataType
NumeratorProductDataType
CustomNumeratorProductDataType
DenominatorProductDataType
CustomDenominatorProductDataType
NumeratorAccumulatorDataType
CustomNumeratorAccumulatorDataType
DenominatorAccumulatorDataType
CustomDenominatorAccumulatorDataType
OutputDataType
CustomOutputDataType
MultiplicandDataType
CustomMultiplicandDataType
    end
    properties
Numerator
Denominator
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=IIRFilter(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.IIRFilter.propListManager');
            coder.extrinsic('dspcodegen.IIRFilter.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.IIRFilter(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.IIRFilter.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.IIRFilter.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'InitialConditions',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'InitialConditions'));
                obj.InitialConditions=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'NumeratorInitialConditions',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'NumeratorInitialConditions'));
                obj.NumeratorInitialConditions=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'DenominatorInitialConditions',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'DenominatorInitialConditions'));
                obj.DenominatorInitialConditions=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'Structure',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'Structure'));
                obj.Structure=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'StateDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'StateDataType'));
                obj.StateDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'CustomStateDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'CustomStateDataType'));
                obj.CustomStateDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'NumeratorCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'NumeratorCoefficientsDataType'));
                obj.NumeratorCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'CustomNumeratorCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'CustomNumeratorCoefficientsDataType'));
                obj.CustomNumeratorCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'DenominatorCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'DenominatorCoefficientsDataType'));
                obj.DenominatorCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'CustomDenominatorCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'CustomDenominatorCoefficientsDataType'));
                obj.CustomDenominatorCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'NumeratorProductDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'NumeratorProductDataType'));
                obj.NumeratorProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'CustomNumeratorProductDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'CustomNumeratorProductDataType'));
                obj.CustomNumeratorProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'DenominatorProductDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'DenominatorProductDataType'));
                obj.DenominatorProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'CustomDenominatorProductDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'CustomDenominatorProductDataType'));
                obj.CustomDenominatorProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'NumeratorAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'NumeratorAccumulatorDataType'));
                obj.NumeratorAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'CustomNumeratorAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'CustomNumeratorAccumulatorDataType'));
                obj.CustomNumeratorAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'DenominatorAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'DenominatorAccumulatorDataType'));
                obj.DenominatorAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'CustomDenominatorAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'CustomDenominatorAccumulatorDataType'));
                obj.CustomDenominatorAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'MultiplicandDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'MultiplicandDataType'));
                obj.MultiplicandDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'CustomMultiplicandDataType',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'CustomMultiplicandDataType'));
                obj.CustomMultiplicandDataType=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'Numerator',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'Numerator'));
                obj.Numerator=val;
            end
            if~coder.internal.const(dspcodegen.IIRFilter.propListManager(s,'Denominator',false))
                val=coder.internal.const(dspcodegen.IIRFilter.getFieldFromMxStruct(propValues,'Denominator'));
                obj.Denominator=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Numerator(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Numerator',val,noTuningError);%#ok<MCSUP>
            obj.Numerator=val;
        end
        function set.Denominator(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Denominator',val,noTuningError);%#ok<MCSUP>
            obj.Denominator=val;
        end
        function set.InitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.InitialConditions=val;
        end
        function set.NumeratorInitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorInitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.NumeratorInitialConditions=val;
        end
        function set.DenominatorInitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorInitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.DenominatorInitialConditions=val;
        end
        function set.Structure(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Structure),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.Structure=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.OverflowAction=val;
        end
        function set.StateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.StateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.StateDataType=val;
        end
        function set.CustomStateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomStateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.CustomStateDataType=val;
        end
        function set.NumeratorCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.NumeratorCoefficientsDataType=val;
        end
        function set.CustomNumeratorCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomNumeratorCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.CustomNumeratorCoefficientsDataType=val;
        end
        function set.DenominatorCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.DenominatorCoefficientsDataType=val;
        end
        function set.CustomDenominatorCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDenominatorCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.CustomDenominatorCoefficientsDataType=val;
        end
        function set.NumeratorProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.NumeratorProductDataType=val;
        end
        function set.CustomNumeratorProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomNumeratorProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.CustomNumeratorProductDataType=val;
        end
        function set.DenominatorProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.DenominatorProductDataType=val;
        end
        function set.CustomDenominatorProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDenominatorProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.CustomDenominatorProductDataType=val;
        end
        function set.NumeratorAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.NumeratorAccumulatorDataType=val;
        end
        function set.CustomNumeratorAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomNumeratorAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.CustomNumeratorAccumulatorDataType=val;
        end
        function set.DenominatorAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.DenominatorAccumulatorDataType=val;
        end
        function set.CustomDenominatorAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDenominatorAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.CustomDenominatorAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.CustomOutputDataType=val;
        end
        function set.MultiplicandDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MultiplicandDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.MultiplicandDataType=val;
        end
        function set.CustomMultiplicandDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomMultiplicandDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.IIRFilter');
            obj.CustomMultiplicandDataType=val;
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
            result='dsp.IIRFilter';
        end
    end
end
