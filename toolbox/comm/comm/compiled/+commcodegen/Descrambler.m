classdef Descrambler<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
CalculationBase
Polynomial
InitialConditionsSource
InitialConditions
ResetInputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=Descrambler(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.Descrambler.propListManager');
            coder.extrinsic('commcodegen.Descrambler.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.Descrambler(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'CalculationBase','Polynomial','InitialConditions');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.Descrambler.propListManager(numValueOnlyProps,'CalculationBase','Polynomial','InitialConditions');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.Descrambler.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.Descrambler.propListManager(s,'CalculationBase',false))
                val=coder.internal.const(commcodegen.Descrambler.getFieldFromMxStruct(propValues,'CalculationBase'));
                obj.CalculationBase=val;
            end
            if~coder.internal.const(commcodegen.Descrambler.propListManager(s,'Polynomial',false))
                val=coder.internal.const(commcodegen.Descrambler.getFieldFromMxStruct(propValues,'Polynomial'));
                obj.Polynomial=val;
            end
            if~coder.internal.const(commcodegen.Descrambler.propListManager(s,'InitialConditionsSource',false))
                val=coder.internal.const(commcodegen.Descrambler.getFieldFromMxStruct(propValues,'InitialConditionsSource'));
                obj.InitialConditionsSource=val;
            end
            if~coder.internal.const(commcodegen.Descrambler.propListManager(s,'InitialConditions',false))
                val=coder.internal.const(commcodegen.Descrambler.getFieldFromMxStruct(propValues,'InitialConditions'));
                obj.InitialConditions=val;
            end
            if~coder.internal.const(commcodegen.Descrambler.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(commcodegen.Descrambler.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.CalculationBase(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CalculationBase),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.Descrambler');
            obj.CalculationBase=val;
        end
        function set.Polynomial(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Polynomial),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.Descrambler');
            obj.Polynomial=val;
        end
        function set.InitialConditionsSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditionsSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.Descrambler');
            obj.InitialConditionsSource=val;
        end
        function set.InitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.Descrambler');
            obj.InitialConditions=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.Descrambler');
            obj.ResetInputPort=val;
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
            result='comm.Descrambler';
        end
    end
end
