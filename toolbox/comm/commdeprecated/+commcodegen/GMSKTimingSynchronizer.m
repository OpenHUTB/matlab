classdef GMSKTimingSynchronizer<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
SamplesPerSymbol
ResetCondition
ResetInputPort
    end
    properties
ErrorUpdateGain
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=GMSKTimingSynchronizer(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.GMSKTimingSynchronizer.propListManager');
            coder.extrinsic('commcodegen.GMSKTimingSynchronizer.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.GMSKTimingSynchronizer(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=commcodegen.GMSKTimingSynchronizer.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.GMSKTimingSynchronizer.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.GMSKTimingSynchronizer.propListManager(s,'SamplesPerSymbol',false))
                val=coder.internal.const(commcodegen.GMSKTimingSynchronizer.getFieldFromMxStruct(propValues,'SamplesPerSymbol'));
                obj.SamplesPerSymbol=val;
            end
            if~coder.internal.const(commcodegen.GMSKTimingSynchronizer.propListManager(s,'ResetCondition',false))
                val=coder.internal.const(commcodegen.GMSKTimingSynchronizer.getFieldFromMxStruct(propValues,'ResetCondition'));
                obj.ResetCondition=val;
            end
            if~coder.internal.const(commcodegen.GMSKTimingSynchronizer.propListManager(s,'ResetInputPort',false))
                val=coder.internal.const(commcodegen.GMSKTimingSynchronizer.getFieldFromMxStruct(propValues,'ResetInputPort'));
                obj.ResetInputPort=val;
            end
            if~coder.internal.const(commcodegen.GMSKTimingSynchronizer.propListManager(s,'ErrorUpdateGain',false))
                val=coder.internal.const(commcodegen.GMSKTimingSynchronizer.getFieldFromMxStruct(propValues,'ErrorUpdateGain'));
                obj.ErrorUpdateGain=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.ErrorUpdateGain(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'ErrorUpdateGain',val,noTuningError);%#ok<MCSUP>
            obj.ErrorUpdateGain=val;
        end
        function set.SamplesPerSymbol(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerSymbol),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKTimingSynchronizer');
            obj.SamplesPerSymbol=val;
        end
        function set.ResetCondition(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetCondition),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKTimingSynchronizer');
            obj.ResetCondition=val;
        end
        function set.ResetInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ResetInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.GMSKTimingSynchronizer');
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
            result='comm.GMSKTimingSynchronizer';
        end
    end
end
