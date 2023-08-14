classdef SineWave<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Frequency
PhaseOffset
Method
TableOptimization
SampleRate
SamplesPerFrame
OutputDataType
CustomOutputDataType
ComplexOutput
    end
    properties
Amplitude
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=SineWave(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.SineWave.propListManager');
            coder.extrinsic('dspcodegen.SineWave.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.SineWave(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Amplitude','Frequency','PhaseOffset');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=dspcodegen.SineWave.propListManager(numValueOnlyProps,'Amplitude','Frequency','PhaseOffset');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.SineWave.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.SineWave.propListManager(s,'Frequency',false))
                val=coder.internal.const(dspcodegen.SineWave.getFieldFromMxStruct(propValues,'Frequency'));
                obj.Frequency=val;
            end
            if~coder.internal.const(dspcodegen.SineWave.propListManager(s,'PhaseOffset',false))
                val=coder.internal.const(dspcodegen.SineWave.getFieldFromMxStruct(propValues,'PhaseOffset'));
                obj.PhaseOffset=val;
            end
            if~coder.internal.const(dspcodegen.SineWave.propListManager(s,'Method',false))
                val=coder.internal.const(dspcodegen.SineWave.getFieldFromMxStruct(propValues,'Method'));
                obj.Method=val;
            end
            if~coder.internal.const(dspcodegen.SineWave.propListManager(s,'TableOptimization',false))
                val=coder.internal.const(dspcodegen.SineWave.getFieldFromMxStruct(propValues,'TableOptimization'));
                obj.TableOptimization=val;
            end
            if~coder.internal.const(dspcodegen.SineWave.propListManager(s,'SampleRate',false))
                val=coder.internal.const(dspcodegen.SineWave.getFieldFromMxStruct(propValues,'SampleRate'));
                obj.SampleRate=val;
            end
            if~coder.internal.const(dspcodegen.SineWave.propListManager(s,'SamplesPerFrame',false))
                val=coder.internal.const(dspcodegen.SineWave.getFieldFromMxStruct(propValues,'SamplesPerFrame'));
                obj.SamplesPerFrame=val;
            end
            if~coder.internal.const(dspcodegen.SineWave.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.SineWave.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.SineWave.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.SineWave.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.SineWave.propListManager(s,'ComplexOutput',false))
                val=coder.internal.const(dspcodegen.SineWave.getFieldFromMxStruct(propValues,'ComplexOutput'));
                obj.ComplexOutput=val;
            end
            if~coder.internal.const(dspcodegen.SineWave.propListManager(s,'Amplitude',false))
                val=coder.internal.const(dspcodegen.SineWave.getFieldFromMxStruct(propValues,'Amplitude'));
                obj.Amplitude=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Amplitude(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Amplitude',val,noTuningError);%#ok<MCSUP>
            obj.Amplitude=val;
        end
        function set.Frequency(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Frequency),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SineWave');
            obj.Frequency=val;
        end
        function set.PhaseOffset(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseOffset),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SineWave');
            obj.PhaseOffset=val;
        end
        function set.Method(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Method),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SineWave');
            obj.Method=val;
        end
        function set.TableOptimization(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TableOptimization),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SineWave');
            obj.TableOptimization=val;
        end
        function set.SampleRate(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SampleRate),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SineWave');
            obj.SampleRate=val;
        end
        function set.SamplesPerFrame(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerFrame),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SineWave');
            obj.SamplesPerFrame=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SineWave');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SineWave');
            obj.CustomOutputDataType=val;
        end
        function set.ComplexOutput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ComplexOutput),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.SineWave');
            obj.ComplexOutput=val;
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
            result='dsp.SineWave';
        end
    end
end
