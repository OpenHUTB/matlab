classdef OSTBCCombiner<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
NumTransmitAntennas
SymbolRate
NumReceiveAntennas
RoundingMethod
OverflowAction
ProductDataType
CustomProductDataType
AccumulatorDataType
CustomAccumulatorDataType
EnergyProductDataType
CustomEnergyProductDataType
EnergyAccumulatorDataType
CustomEnergyAccumulatorDataType
DivisionDataType
CustomDivisionDataType
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=OSTBCCombiner(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.OSTBCCombiner.propListManager');
            coder.extrinsic('commcodegen.OSTBCCombiner.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.OSTBCCombiner(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'NumTransmitAntennas','NumReceiveAntennas');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.OSTBCCombiner.propListManager(numValueOnlyProps,'NumTransmitAntennas','NumReceiveAntennas');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.OSTBCCombiner.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'NumTransmitAntennas',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'NumTransmitAntennas'));
                obj.NumTransmitAntennas=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'SymbolRate',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'SymbolRate'));
                obj.SymbolRate=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'NumReceiveAntennas',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'NumReceiveAntennas'));
                obj.NumReceiveAntennas=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'EnergyProductDataType',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'EnergyProductDataType'));
                obj.EnergyProductDataType=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'CustomEnergyProductDataType',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'CustomEnergyProductDataType'));
                obj.CustomEnergyProductDataType=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'EnergyAccumulatorDataType',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'EnergyAccumulatorDataType'));
                obj.EnergyAccumulatorDataType=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'CustomEnergyAccumulatorDataType',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'CustomEnergyAccumulatorDataType'));
                obj.CustomEnergyAccumulatorDataType=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'DivisionDataType',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'DivisionDataType'));
                obj.DivisionDataType=val;
            end
            if~coder.internal.const(commcodegen.OSTBCCombiner.propListManager(s,'CustomDivisionDataType',false))
                val=coder.internal.const(commcodegen.OSTBCCombiner.getFieldFromMxStruct(propValues,'CustomDivisionDataType'));
                obj.CustomDivisionDataType=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.NumTransmitAntennas(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumTransmitAntennas),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.NumTransmitAntennas=val;
        end
        function set.SymbolRate(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SymbolRate),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.SymbolRate=val;
        end
        function set.NumReceiveAntennas(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumReceiveAntennas),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.NumReceiveAntennas=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.OverflowAction=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.CustomProductDataType=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.CustomAccumulatorDataType=val;
        end
        function set.EnergyProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.EnergyProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.EnergyProductDataType=val;
        end
        function set.CustomEnergyProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomEnergyProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.CustomEnergyProductDataType=val;
        end
        function set.EnergyAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.EnergyAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.EnergyAccumulatorDataType=val;
        end
        function set.CustomEnergyAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomEnergyAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.CustomEnergyAccumulatorDataType=val;
        end
        function set.DivisionDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DivisionDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.DivisionDataType=val;
        end
        function set.CustomDivisionDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDivisionDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.OSTBCCombiner');
            obj.CustomDivisionDataType=val;
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
            result='comm.OSTBCCombiner';
        end
    end
end
