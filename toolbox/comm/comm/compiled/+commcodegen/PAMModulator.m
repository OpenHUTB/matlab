classdef PAMModulator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
ModulationOrder
SymbolMapping
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
        function obj=PAMModulator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.PAMModulator.propListManager');
            coder.extrinsic('commcodegen.PAMModulator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.PAMModulator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'ModulationOrder');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.PAMModulator.propListManager(numValueOnlyProps,'ModulationOrder');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.PAMModulator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.PAMModulator.propListManager(s,'ModulationOrder',false))
                val=coder.internal.const(commcodegen.PAMModulator.getFieldFromMxStruct(propValues,'ModulationOrder'));
                obj.ModulationOrder=val;
            end
            if~coder.internal.const(commcodegen.PAMModulator.propListManager(s,'SymbolMapping',false))
                val=coder.internal.const(commcodegen.PAMModulator.getFieldFromMxStruct(propValues,'SymbolMapping'));
                obj.SymbolMapping=val;
            end
            if~coder.internal.const(commcodegen.PAMModulator.propListManager(s,'NormalizationMethod',false))
                val=coder.internal.const(commcodegen.PAMModulator.getFieldFromMxStruct(propValues,'NormalizationMethod'));
                obj.NormalizationMethod=val;
            end
            if~coder.internal.const(commcodegen.PAMModulator.propListManager(s,'MinimumDistance',false))
                val=coder.internal.const(commcodegen.PAMModulator.getFieldFromMxStruct(propValues,'MinimumDistance'));
                obj.MinimumDistance=val;
            end
            if~coder.internal.const(commcodegen.PAMModulator.propListManager(s,'AveragePower',false))
                val=coder.internal.const(commcodegen.PAMModulator.getFieldFromMxStruct(propValues,'AveragePower'));
                obj.AveragePower=val;
            end
            if~coder.internal.const(commcodegen.PAMModulator.propListManager(s,'PeakPower',false))
                val=coder.internal.const(commcodegen.PAMModulator.getFieldFromMxStruct(propValues,'PeakPower'));
                obj.PeakPower=val;
            end
            if~coder.internal.const(commcodegen.PAMModulator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.PAMModulator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.PAMModulator.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(commcodegen.PAMModulator.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(commcodegen.PAMModulator.propListManager(s,'BitInput',false))
                val=coder.internal.const(commcodegen.PAMModulator.getFieldFromMxStruct(propValues,'BitInput'));
                obj.BitInput=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.ModulationOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ModulationOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PAMModulator');
            obj.ModulationOrder=val;
        end
        function set.SymbolMapping(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SymbolMapping),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PAMModulator');
            obj.SymbolMapping=val;
        end
        function set.NormalizationMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NormalizationMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PAMModulator');
            obj.NormalizationMethod=val;
        end
        function set.MinimumDistance(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MinimumDistance),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PAMModulator');
            obj.MinimumDistance=val;
        end
        function set.AveragePower(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AveragePower),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PAMModulator');
            obj.AveragePower=val;
        end
        function set.PeakPower(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PeakPower),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PAMModulator');
            obj.PeakPower=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PAMModulator');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PAMModulator');
            obj.CustomOutputDataType=val;
        end
        function set.BitInput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BitInput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PAMModulator');
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
            result='comm.PAMModulator';
        end
    end
end
