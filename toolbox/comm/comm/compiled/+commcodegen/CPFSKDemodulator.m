classdef CPFSKDemodulator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
BitOutput
ModulationOrder
SymbolMapping
ModulationIndex
InitialPhaseOffset
SamplesPerSymbol
TracebackDepth
OutputDataType
pBitDataType
pIntDataType
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=CPFSKDemodulator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.CPFSKDemodulator.propListManager');
            coder.extrinsic('commcodegen.CPFSKDemodulator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.CPFSKDemodulator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'ModulationOrder');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.CPFSKDemodulator.propListManager(numValueOnlyProps,'ModulationOrder');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.CPFSKDemodulator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.CPFSKDemodulator.propListManager(s,'BitOutput',false))
                val=coder.internal.const(commcodegen.CPFSKDemodulator.getFieldFromMxStruct(propValues,'BitOutput'));
                obj.BitOutput=val;
            end
            if~coder.internal.const(commcodegen.CPFSKDemodulator.propListManager(s,'ModulationOrder',false))
                val=coder.internal.const(commcodegen.CPFSKDemodulator.getFieldFromMxStruct(propValues,'ModulationOrder'));
                obj.ModulationOrder=val;
            end
            if~coder.internal.const(commcodegen.CPFSKDemodulator.propListManager(s,'SymbolMapping',false))
                val=coder.internal.const(commcodegen.CPFSKDemodulator.getFieldFromMxStruct(propValues,'SymbolMapping'));
                obj.SymbolMapping=val;
            end
            if~coder.internal.const(commcodegen.CPFSKDemodulator.propListManager(s,'ModulationIndex',false))
                val=coder.internal.const(commcodegen.CPFSKDemodulator.getFieldFromMxStruct(propValues,'ModulationIndex'));
                obj.ModulationIndex=val;
            end
            if~coder.internal.const(commcodegen.CPFSKDemodulator.propListManager(s,'InitialPhaseOffset',false))
                val=coder.internal.const(commcodegen.CPFSKDemodulator.getFieldFromMxStruct(propValues,'InitialPhaseOffset'));
                obj.InitialPhaseOffset=val;
            end
            if~coder.internal.const(commcodegen.CPFSKDemodulator.propListManager(s,'SamplesPerSymbol',false))
                val=coder.internal.const(commcodegen.CPFSKDemodulator.getFieldFromMxStruct(propValues,'SamplesPerSymbol'));
                obj.SamplesPerSymbol=val;
            end
            if~coder.internal.const(commcodegen.CPFSKDemodulator.propListManager(s,'TracebackDepth',false))
                val=coder.internal.const(commcodegen.CPFSKDemodulator.getFieldFromMxStruct(propValues,'TracebackDepth'));
                obj.TracebackDepth=val;
            end
            if~coder.internal.const(commcodegen.CPFSKDemodulator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.CPFSKDemodulator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.CPFSKDemodulator.propListManager(s,'pBitDataType',false))
                val=coder.internal.const(get(obj.cSFunObject,'pBitDataType'));
                obj.pBitDataType=val;
            end
            if~coder.internal.const(commcodegen.CPFSKDemodulator.propListManager(s,'pIntDataType',false))
                val=coder.internal.const(get(obj.cSFunObject,'pIntDataType'));
                obj.pIntDataType=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.BitOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BitOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CPFSKDemodulator');
            obj.BitOutput=val;
        end
        function set.ModulationOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ModulationOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CPFSKDemodulator');
            obj.ModulationOrder=val;
        end
        function set.SymbolMapping(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SymbolMapping),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CPFSKDemodulator');
            obj.SymbolMapping=val;
        end
        function set.ModulationIndex(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ModulationIndex),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CPFSKDemodulator');
            obj.ModulationIndex=val;
        end
        function set.InitialPhaseOffset(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialPhaseOffset),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CPFSKDemodulator');
            obj.InitialPhaseOffset=val;
        end
        function set.SamplesPerSymbol(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerSymbol),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CPFSKDemodulator');
            obj.SamplesPerSymbol=val;
        end
        function set.TracebackDepth(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TracebackDepth),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CPFSKDemodulator');
            obj.TracebackDepth=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CPFSKDemodulator');
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
            result='comm.CPFSKDemodulator';
        end
    end
end
