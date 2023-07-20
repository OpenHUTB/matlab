classdef SOSFilter<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Structure
CoefficientSource
HasScaleValues
RoundingMethod
OverflowAction
SectionInputDataType
SectionOutputDataType
NumeratorDataType
DenominatorDataType
ScaleValuesDataType
StateDataType
MultiplicandDataType
DenominatorAccumulatorDataType
OutputDataType
    end
    properties
Numerator
Denominator
ScaleValues
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=SOSFilter(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.SOSFilter.propListManager');
            coder.extrinsic('dspcodegen.SOSFilter.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.SOSFilter(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Numerator','Denominator');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=dspcodegen.SOSFilter.propListManager(numValueOnlyProps,'Numerator','Denominator');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.SOSFilter.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'Structure',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'Structure'));
                obj.Structure=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'CoefficientSource',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'CoefficientSource'));
                obj.CoefficientSource=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'HasScaleValues',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'HasScaleValues'));
                obj.HasScaleValues=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'SectionInputDataType',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'SectionInputDataType'));
                obj.SectionInputDataType=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'SectionOutputDataType',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'SectionOutputDataType'));
                obj.SectionOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'NumeratorDataType',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'NumeratorDataType'));
                obj.NumeratorDataType=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'DenominatorDataType',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'DenominatorDataType'));
                obj.DenominatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'ScaleValuesDataType',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'ScaleValuesDataType'));
                obj.ScaleValuesDataType=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'StateDataType',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'StateDataType'));
                obj.StateDataType=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'MultiplicandDataType',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'MultiplicandDataType'));
                obj.MultiplicandDataType=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'DenominatorAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'DenominatorAccumulatorDataType'));
                obj.DenominatorAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'Numerator',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'Numerator'));
                obj.Numerator=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'Denominator',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'Denominator'));
                obj.Denominator=val;
            end
            if~coder.internal.const(dspcodegen.SOSFilter.propListManager(s,'ScaleValues',false))
                val=coder.internal.const(dspcodegen.SOSFilter.getFieldFromMxStruct(propValues,'ScaleValues'));
                obj.ScaleValues=val;
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
            setSfunSystemObject(obj.cSFunObject,'Numerator',val,noTuningError);%#ok<MCSUP>
            obj.Numerator=val;
        end
        function set.Denominator(obj,val)
            coder.inline('always');
            noTuningError=true;
            if coder.internal.const(~coder.target('Rtw'))
                noTuningError=obj.NoTuningBeforeLockingCodeGenError;
            end
            setSfunSystemObject(obj.cSFunObject,'Denominator',val,noTuningError);%#ok<MCSUP>
            obj.Denominator=val;
        end
        function set.ScaleValues(obj,val)
            coder.inline('always');
            noTuningError=true;
            if coder.internal.const(~coder.target('Rtw'))
                noTuningError=obj.NoTuningBeforeLockingCodeGenError;
            end
            setSfunSystemObject(obj.cSFunObject,'ScaleValues',val,noTuningError);%#ok<MCSUP>
            obj.ScaleValues=val;
        end
        function set.Structure(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Structure),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.Structure=val;
        end
        function set.CoefficientSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CoefficientSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.CoefficientSource=val;
        end
        function set.HasScaleValues(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.HasScaleValues),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.HasScaleValues=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.OverflowAction=val;
        end
        function set.SectionInputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SectionInputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.SectionInputDataType=val;
        end
        function set.SectionOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SectionOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.SectionOutputDataType=val;
        end
        function set.NumeratorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumeratorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.NumeratorDataType=val;
        end
        function set.DenominatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.DenominatorDataType=val;
        end
        function set.ScaleValuesDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ScaleValuesDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.ScaleValuesDataType=val;
        end
        function set.StateDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.StateDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.StateDataType=val;
        end
        function set.MultiplicandDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MultiplicandDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.MultiplicandDataType=val;
        end
        function set.DenominatorAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DenominatorAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
            obj.DenominatorAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SOSFilter');
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
            result='dsp.SOSFilter';
        end
    end
end
