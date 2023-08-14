classdef FIRFilter<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
ReflectionCoefficients
InitialConditions
NumeratorSource
ReflectionCoefficientsSource
Structure
FullPrecisionOverride
RoundingMethod
OverflowAction
CoefficientsDataType
ReflectionCoefficientsDataType
CustomCoefficientsDataType
CustomReflectionCoefficientsDataType
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
StateDataType
CustomStateDataType
OutputDataType
CustomOutputDataType
CoderTarget
    end
    properties
Numerator
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=FIRFilter(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.FIRFilter.propListManager');
            coder.extrinsic('dspcodegen.FIRFilter.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.FIRFilter(varargin{:},'CoderTarget',coder.target);
            obj.ConstructorArgs=varargin;
            s=dspcodegen.FIRFilter.propListManager();
            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'ReflectionCoefficients',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'ReflectionCoefficients'));
                obj.ReflectionCoefficients=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'InitialConditions',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'InitialConditions'));
                obj.InitialConditions=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'NumeratorSource',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'NumeratorSource'));
                obj.NumeratorSource=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'ReflectionCoefficientsSource',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'ReflectionCoefficientsSource'));
                obj.ReflectionCoefficientsSource=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'Structure',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'Structure'));
                obj.Structure=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'FullPrecisionOverride',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'FullPrecisionOverride'));
                obj.FullPrecisionOverride=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'CoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'CoefficientsDataType'));
                obj.CoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'ReflectionCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'ReflectionCoefficientsDataType'));
                obj.ReflectionCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'CustomCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'CustomCoefficientsDataType'));
                obj.CustomCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'CustomReflectionCoefficientsDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'CustomReflectionCoefficientsDataType'));
                obj.CustomReflectionCoefficientsDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'StateDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'StateDataType'));
                obj.StateDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'CustomStateDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'CustomStateDataType'));
                obj.CustomStateDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'Numerator',false))
                val=coder.internal.const(dspcodegen.FIRFilter.getFieldFromMxStruct(propValues,'Numerator'));
                obj.Numerator=val;
            end
            if~coder.internal.const(dspcodegen.FIRFilter.propListManager(s,'CoderTarget',false))
                val=coder.internal.const(get(obj.cSFunObject,'CoderTarget'));
                obj.CoderTarget=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Numerator(obj,val)
            coder.inline('always');
            noTuningError=true;
            if coder.internal.const(~coder.target('Rtw'))
                noTuningError=obj.NoTuningBeforeLockingCodeGenError;
            end
            if~strncmp(obj.Structure,'Lattice',7)
                setSfunSystemObject(obj.cSFunObject,'Numerator',val,noTuningError);%#ok<MCSUP>
            end
            obj.Numerator=val;
        end
        function set.ReflectionCoefficients(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ReflectionCoefficients),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.ReflectionCoefficients=val;
        end
        function set.InitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.InitialConditions=val;
        end
        function set.NumeratorSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.NumeratorSource=val;
        end
        function set.ReflectionCoefficientsSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ReflectionCoefficientsSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.ReflectionCoefficientsSource=val;
        end
        function set.Structure(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Structure),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.Structure=val;
        end
        function set.FullPrecisionOverride(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FullPrecisionOverride),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.FullPrecisionOverride=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.OverflowAction=val;
        end
        function set.CoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.CoefficientsDataType=val;
        end
        function set.ReflectionCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ReflectionCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.ReflectionCoefficientsDataType=val;
        end
        function set.CustomCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.CustomCoefficientsDataType=val;
        end
        function set.CustomReflectionCoefficientsDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomReflectionCoefficientsDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.CustomReflectionCoefficientsDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.CustomAccumulatorDataType=val;
        end
        function set.StateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.StateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.StateDataType=val;
        end
        function set.CustomStateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomStateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.CustomStateDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.FIRFilter');
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
            result='dsp.FIRFilter';
        end
    end
end
