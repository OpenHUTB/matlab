classdef FSKDemodulator<matlab.System
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
FrequencySeparation
SamplesPerSymbol
SymbolRate
OutputDataType
BitOutput
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=FSKDemodulator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.FSKDemodulator.propListManager');
            coder.extrinsic('commcodegen.FSKDemodulator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.FSKDemodulator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'ModulationOrder','FrequencySeparation','SymbolRate');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.FSKDemodulator.propListManager(numValueOnlyProps,'ModulationOrder','FrequencySeparation','SymbolRate');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.FSKDemodulator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.FSKDemodulator.propListManager(s,'ModulationOrder',false))
                val=coder.internal.const(commcodegen.FSKDemodulator.getFieldFromMxStruct(propValues,'ModulationOrder'));
                obj.ModulationOrder=val;
            end
            if~coder.internal.const(commcodegen.FSKDemodulator.propListManager(s,'SymbolMapping',false))
                val=coder.internal.const(commcodegen.FSKDemodulator.getFieldFromMxStruct(propValues,'SymbolMapping'));
                obj.SymbolMapping=val;
            end
            if~coder.internal.const(commcodegen.FSKDemodulator.propListManager(s,'FrequencySeparation',false))
                val=coder.internal.const(commcodegen.FSKDemodulator.getFieldFromMxStruct(propValues,'FrequencySeparation'));
                obj.FrequencySeparation=val;
            end
            if~coder.internal.const(commcodegen.FSKDemodulator.propListManager(s,'SamplesPerSymbol',false))
                val=coder.internal.const(commcodegen.FSKDemodulator.getFieldFromMxStruct(propValues,'SamplesPerSymbol'));
                obj.SamplesPerSymbol=val;
            end
            if~coder.internal.const(commcodegen.FSKDemodulator.propListManager(s,'SymbolRate',false))
                val=coder.internal.const(commcodegen.FSKDemodulator.getFieldFromMxStruct(propValues,'SymbolRate'));
                obj.SymbolRate=val;
            end
            if~coder.internal.const(commcodegen.FSKDemodulator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.FSKDemodulator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.FSKDemodulator.propListManager(s,'BitOutput',false))
                val=coder.internal.const(commcodegen.FSKDemodulator.getFieldFromMxStruct(propValues,'BitOutput'));
                obj.BitOutput=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.ModulationOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ModulationOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.FSKDemodulator');
            obj.ModulationOrder=val;
        end
        function set.SymbolMapping(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SymbolMapping),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.FSKDemodulator');
            obj.SymbolMapping=val;
        end
        function set.FrequencySeparation(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FrequencySeparation),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.FSKDemodulator');
            obj.FrequencySeparation=val;
        end
        function set.SamplesPerSymbol(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerSymbol),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.FSKDemodulator');
            obj.SamplesPerSymbol=val;
        end
        function set.SymbolRate(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SymbolRate),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.FSKDemodulator');
            obj.SymbolRate=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.FSKDemodulator');
            obj.OutputDataType=val;
        end
        function set.BitOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BitOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.FSKDemodulator');
            obj.BitOutput=val;
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
            result='comm.FSKDemodulator';
        end
    end
end
