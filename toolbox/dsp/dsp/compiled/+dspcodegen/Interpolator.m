classdef Interpolator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
InterpolationPointsSource
Method
FilterHalfLength
InterpolationPointsPerSample
Bandwidth
    end
    properties
InterpolationPoints
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=Interpolator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.Interpolator.propListManager');
            coder.extrinsic('dspcodegen.Interpolator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.Interpolator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.Interpolator.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.Interpolator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.Interpolator.propListManager(s,'InterpolationPointsSource',false))
                val=coder.internal.const(dspcodegen.Interpolator.getFieldFromMxStruct(propValues,'InterpolationPointsSource'));
                obj.InterpolationPointsSource=val;
            end
            if~coder.internal.const(dspcodegen.Interpolator.propListManager(s,'Method',false))
                val=coder.internal.const(dspcodegen.Interpolator.getFieldFromMxStruct(propValues,'Method'));
                obj.Method=val;
            end
            if~coder.internal.const(dspcodegen.Interpolator.propListManager(s,'FilterHalfLength',false))
                val=coder.internal.const(dspcodegen.Interpolator.getFieldFromMxStruct(propValues,'FilterHalfLength'));
                obj.FilterHalfLength=val;
            end
            if~coder.internal.const(dspcodegen.Interpolator.propListManager(s,'InterpolationPointsPerSample',false))
                val=coder.internal.const(dspcodegen.Interpolator.getFieldFromMxStruct(propValues,'InterpolationPointsPerSample'));
                obj.InterpolationPointsPerSample=val;
            end
            if~coder.internal.const(dspcodegen.Interpolator.propListManager(s,'Bandwidth',false))
                val=coder.internal.const(dspcodegen.Interpolator.getFieldFromMxStruct(propValues,'Bandwidth'));
                obj.Bandwidth=val;
            end
            if~coder.internal.const(dspcodegen.Interpolator.propListManager(s,'InterpolationPoints',false))
                val=coder.internal.const(dspcodegen.Interpolator.getFieldFromMxStruct(propValues,'InterpolationPoints'));
                obj.InterpolationPoints=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.InterpolationPoints(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'InterpolationPoints',val,noTuningError);%#ok<MCSUP>
            obj.InterpolationPoints=val;
        end
        function set.InterpolationPointsSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InterpolationPointsSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Interpolator');
            obj.InterpolationPointsSource=val;
        end
        function set.Method(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Method),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Interpolator');
            obj.Method=val;
        end
        function set.FilterHalfLength(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FilterHalfLength),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Interpolator');
            obj.FilterHalfLength=val;
        end
        function set.InterpolationPointsPerSample(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InterpolationPointsPerSample),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Interpolator');
            obj.InterpolationPointsPerSample=val;
        end
        function set.Bandwidth(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Bandwidth),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Interpolator');
            obj.Bandwidth=val;
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
            result='dsp.Interpolator';
        end
    end
end
