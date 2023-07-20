classdef BPSKDemodulator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
PhaseOffset
DecisionMethod
VarianceSource
OutputDataType
DerotateFactorDataType
CustomDerotateFactorDataType
    end
    properties
Variance
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=BPSKDemodulator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.BPSKDemodulator.propListManager');
            coder.extrinsic('commcodegen.BPSKDemodulator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.BPSKDemodulator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'PhaseOffset');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.BPSKDemodulator.propListManager(numValueOnlyProps,'PhaseOffset');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.BPSKDemodulator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.BPSKDemodulator.propListManager(s,'PhaseOffset',false))
                val=coder.internal.const(commcodegen.BPSKDemodulator.getFieldFromMxStruct(propValues,'PhaseOffset'));
                obj.PhaseOffset=val;
            end
            if~coder.internal.const(commcodegen.BPSKDemodulator.propListManager(s,'DecisionMethod',false))
                val=coder.internal.const(commcodegen.BPSKDemodulator.getFieldFromMxStruct(propValues,'DecisionMethod'));
                obj.DecisionMethod=val;
            end
            if~coder.internal.const(commcodegen.BPSKDemodulator.propListManager(s,'VarianceSource',false))
                val=coder.internal.const(commcodegen.BPSKDemodulator.getFieldFromMxStruct(propValues,'VarianceSource'));
                obj.VarianceSource=val;
            end
            if~coder.internal.const(commcodegen.BPSKDemodulator.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(commcodegen.BPSKDemodulator.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(commcodegen.BPSKDemodulator.propListManager(s,'DerotateFactorDataType',false))
                val=coder.internal.const(commcodegen.BPSKDemodulator.getFieldFromMxStruct(propValues,'DerotateFactorDataType'));
                obj.DerotateFactorDataType=val;
            end
            if~coder.internal.const(commcodegen.BPSKDemodulator.propListManager(s,'CustomDerotateFactorDataType',false))
                val=coder.internal.const(commcodegen.BPSKDemodulator.getFieldFromMxStruct(propValues,'CustomDerotateFactorDataType'));
                obj.CustomDerotateFactorDataType=val;
            end
            if~coder.internal.const(commcodegen.BPSKDemodulator.propListManager(s,'Variance',false))
                val=coder.internal.const(commcodegen.BPSKDemodulator.getFieldFromMxStruct(propValues,'Variance'));
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
        function set.PhaseOffset(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseOffset),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BPSKDemodulator');
            obj.PhaseOffset=val;
        end
        function set.DecisionMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DecisionMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BPSKDemodulator');
            obj.DecisionMethod=val;
        end
        function set.VarianceSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VarianceSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BPSKDemodulator');
            obj.VarianceSource=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BPSKDemodulator');
            obj.OutputDataType=val;
        end
        function set.DerotateFactorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DerotateFactorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BPSKDemodulator');
            obj.DerotateFactorDataType=val;
        end
        function set.CustomDerotateFactorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomDerotateFactorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.BPSKDemodulator');
            obj.CustomDerotateFactorDataType=val;
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
            result='comm.BPSKDemodulator';
        end
    end
end
