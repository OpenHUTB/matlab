classdef PSKDemodulator<matlab.System
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
DerotateFactorDataType
CustomDerotateFactorDataType
BitOutput
OutputDataType
    end
    properties
Variance
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=PSKDemodulator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.PSKDemodulator.propListManager');
            coder.extrinsic('commcodegen.PSKDemodulator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.PSKDemodulator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'ModulationOrder','PhaseOffset');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.PSKDemodulator.propListManager(numValueOnlyProps,'ModulationOrder','PhaseOffset');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.PSKDemodulator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'DecisionMethod',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'DecisionMethod'));
                obj.DecisionMethod=val;
            end
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'VarianceSource',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'VarianceSource'));
                obj.VarianceSource=val;
            end
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'ModulationOrder',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'ModulationOrder'));
                obj.ModulationOrder=val;
            end
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'PhaseOffset',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'PhaseOffset'));
                obj.PhaseOffset=val;
            end
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'SymbolMapping',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'SymbolMapping'));
                obj.SymbolMapping=val;
            end
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'CustomSymbolMapping',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'CustomSymbolMapping'));
                obj.CustomSymbolMapping=val;
            end
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'DerotateFactorDataType',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'DerotateFactorDataType'));
                obj.DerotateFactorDataType=val;
            end
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'CustomDerotateFactorDataType',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'CustomDerotateFactorDataType'));
                obj.CustomDerotateFactorDataType=val;
            end
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'BitOutput',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'BitOutput'));
                obj.BitOutput=val;
            end
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.PSKDemodulator.propListManager(s,'Variance',false))
                val=coder.internal.const(commcodegen.PSKDemodulator.getFieldFromMxStruct(propValues,'Variance'));
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
            coder.internal.errorIf(coder.internal.is_defined(obj.DecisionMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PSKDemodulator');
            obj.DecisionMethod=val;
        end
        function set.VarianceSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VarianceSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PSKDemodulator');
            obj.VarianceSource=val;
        end
        function set.ModulationOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ModulationOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PSKDemodulator');
            obj.ModulationOrder=val;
        end
        function set.PhaseOffset(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseOffset),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PSKDemodulator');
            obj.PhaseOffset=val;
        end
        function set.SymbolMapping(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SymbolMapping),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PSKDemodulator');
            obj.SymbolMapping=val;
        end
        function set.CustomSymbolMapping(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomSymbolMapping),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PSKDemodulator');
            obj.CustomSymbolMapping=val;
        end
        function set.DerotateFactorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DerotateFactorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PSKDemodulator');
            obj.DerotateFactorDataType=val;
        end
        function set.CustomDerotateFactorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDerotateFactorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PSKDemodulator');
            obj.CustomDerotateFactorDataType=val;
        end
        function set.BitOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BitOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PSKDemodulator');
            obj.BitOutput=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.PSKDemodulator');
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
            result='comm.PSKDemodulator';
        end
    end
end
