classdef GammaCorrector<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Correction
Gamma
BreakPoint
LinearSegment
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=GammaCorrector(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.GammaCorrector.propListManager');
            coder.extrinsic('visioncodegen.GammaCorrector.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.GammaCorrector(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Gamma');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=visioncodegen.GammaCorrector.propListManager(numValueOnlyProps,'Gamma');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.GammaCorrector.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.GammaCorrector.propListManager(s,'Correction',false))
                val=coder.internal.const(visioncodegen.GammaCorrector.getFieldFromMxStruct(propValues,'Correction'));
                obj.Correction=val;
            end
            if~coder.internal.const(visioncodegen.GammaCorrector.propListManager(s,'Gamma',false))
                val=coder.internal.const(visioncodegen.GammaCorrector.getFieldFromMxStruct(propValues,'Gamma'));
                obj.Gamma=val;
            end
            if~coder.internal.const(visioncodegen.GammaCorrector.propListManager(s,'BreakPoint',false))
                val=coder.internal.const(visioncodegen.GammaCorrector.getFieldFromMxStruct(propValues,'BreakPoint'));
                obj.BreakPoint=val;
            end
            if~coder.internal.const(visioncodegen.GammaCorrector.propListManager(s,'LinearSegment',false))
                val=coder.internal.const(visioncodegen.GammaCorrector.getFieldFromMxStruct(propValues,'LinearSegment'));
                obj.LinearSegment=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Correction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Correction),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GammaCorrector');
            obj.Correction=val;
        end
        function set.Gamma(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Gamma),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GammaCorrector');
            obj.Gamma=val;
        end
        function set.BreakPoint(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BreakPoint),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GammaCorrector');
            obj.BreakPoint=val;
        end
        function set.LinearSegment(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.LinearSegment),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.GammaCorrector');
            obj.LinearSegment=val;
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
            result='vision.GammaCorrector';
        end
    end
end
