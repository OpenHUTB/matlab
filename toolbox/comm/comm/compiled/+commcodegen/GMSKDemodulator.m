classdef GMSKDemodulator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
BitOutput
BandwidthTimeProduct
PulseLength
SymbolPrehistory
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
        function obj=GMSKDemodulator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.GMSKDemodulator.propListManager');
            coder.extrinsic('commcodegen.GMSKDemodulator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.GMSKDemodulator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=commcodegen.GMSKDemodulator.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.GMSKDemodulator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.GMSKDemodulator.propListManager(s,'BitOutput',false))
                val=coder.internal.const(commcodegen.GMSKDemodulator.getFieldFromMxStruct(propValues,'BitOutput'));
                obj.BitOutput=val;
            end
            if~coder.internal.const(commcodegen.GMSKDemodulator.propListManager(s,'BandwidthTimeProduct',false))
                val=coder.internal.const(commcodegen.GMSKDemodulator.getFieldFromMxStruct(propValues,'BandwidthTimeProduct'));
                obj.BandwidthTimeProduct=val;
            end
            if~coder.internal.const(commcodegen.GMSKDemodulator.propListManager(s,'PulseLength',false))
                val=coder.internal.const(commcodegen.GMSKDemodulator.getFieldFromMxStruct(propValues,'PulseLength'));
                obj.PulseLength=val;
            end
            if~coder.internal.const(commcodegen.GMSKDemodulator.propListManager(s,'SymbolPrehistory',false))
                val=coder.internal.const(commcodegen.GMSKDemodulator.getFieldFromMxStruct(propValues,'SymbolPrehistory'));
                obj.SymbolPrehistory=val;
            end
            if~coder.internal.const(commcodegen.GMSKDemodulator.propListManager(s,'InitialPhaseOffset',false))
                val=coder.internal.const(commcodegen.GMSKDemodulator.getFieldFromMxStruct(propValues,'InitialPhaseOffset'));
                obj.InitialPhaseOffset=val;
            end
            if~coder.internal.const(commcodegen.GMSKDemodulator.propListManager(s,'SamplesPerSymbol',false))
                val=coder.internal.const(commcodegen.GMSKDemodulator.getFieldFromMxStruct(propValues,'SamplesPerSymbol'));
                obj.SamplesPerSymbol=val;
            end
            if~coder.internal.const(commcodegen.GMSKDemodulator.propListManager(s,'TracebackDepth',false))
                val=coder.internal.const(commcodegen.GMSKDemodulator.getFieldFromMxStruct(propValues,'TracebackDepth'));
                obj.TracebackDepth=val;
            end
            if~coder.internal.const(commcodegen.GMSKDemodulator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.GMSKDemodulator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.GMSKDemodulator.propListManager(s,'pBitDataType',false))
                val=coder.internal.const(get(obj.cSFunObject,'pBitDataType'));
                obj.pBitDataType=val;
            end
            if~coder.internal.const(commcodegen.GMSKDemodulator.propListManager(s,'pIntDataType',false))
                val=coder.internal.const(get(obj.cSFunObject,'pIntDataType'));
                obj.pIntDataType=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.BitOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BitOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKDemodulator');
            obj.BitOutput=val;
        end
        function set.BandwidthTimeProduct(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BandwidthTimeProduct),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKDemodulator');
            obj.BandwidthTimeProduct=val;
        end
        function set.PulseLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PulseLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKDemodulator');
            obj.PulseLength=val;
        end
        function set.SymbolPrehistory(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SymbolPrehistory),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKDemodulator');
            obj.SymbolPrehistory=val;
        end
        function set.InitialPhaseOffset(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialPhaseOffset),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKDemodulator');
            obj.InitialPhaseOffset=val;
        end
        function set.SamplesPerSymbol(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerSymbol),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKDemodulator');
            obj.SamplesPerSymbol=val;
        end
        function set.TracebackDepth(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TracebackDepth),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKDemodulator');
            obj.TracebackDepth=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKDemodulator');
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
            result='comm.GMSKDemodulator';
        end
    end
end
