classdef RectangularQAMModulator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
ModulationOrder
PhaseOffset
SymbolMapping
CustomSymbolMapping
NormalizationMethod
MinimumDistance
AveragePower
PeakPower
OutputDataType
CustomOutputDataType
BitInput
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=RectangularQAMModulator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.RectangularQAMModulator.propListManager');
            coder.extrinsic('commcodegen.RectangularQAMModulator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.RectangularQAMModulator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'ModulationOrder');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.RectangularQAMModulator.propListManager(numValueOnlyProps,'ModulationOrder');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.RectangularQAMModulator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'ModulationOrder',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'ModulationOrder'));
                obj.ModulationOrder=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'PhaseOffset',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'PhaseOffset'));
                obj.PhaseOffset=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'SymbolMapping',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'SymbolMapping'));
                obj.SymbolMapping=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'CustomSymbolMapping',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'CustomSymbolMapping'));
                obj.CustomSymbolMapping=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'NormalizationMethod',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'NormalizationMethod'));
                obj.NormalizationMethod=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'MinimumDistance',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'MinimumDistance'));
                obj.MinimumDistance=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'AveragePower',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'AveragePower'));
                obj.AveragePower=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'PeakPower',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'PeakPower'));
                obj.PeakPower=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(commcodegen.RectangularQAMModulator.propListManager(s,'BitInput',false))
                val=coder.internal.const(commcodegen.RectangularQAMModulator.getFieldFromMxStruct(propValues,'BitInput'));
                obj.BitInput=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.ModulationOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ModulationOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.ModulationOrder=val;
        end
        function set.PhaseOffset(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseOffset),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.PhaseOffset=val;
        end
        function set.SymbolMapping(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SymbolMapping),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.SymbolMapping=val;
        end
        function set.CustomSymbolMapping(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomSymbolMapping),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.CustomSymbolMapping=val;
        end
        function set.NormalizationMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NormalizationMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.NormalizationMethod=val;
        end
        function set.MinimumDistance(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MinimumDistance),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.MinimumDistance=val;
        end
        function set.AveragePower(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AveragePower),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.AveragePower=val;
        end
        function set.PeakPower(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PeakPower),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.PeakPower=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.CustomOutputDataType=val;
        end
        function set.BitInput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BitInput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.RectangularQAMModulator');
            obj.BitInput=val;
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
            result='comm.RectangularQAMModulator';
        end
    end
end
