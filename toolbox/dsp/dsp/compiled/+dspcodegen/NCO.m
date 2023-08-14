classdef NCO<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
PhaseIncrementSource
PhaseIncrement
PhaseOffsetSource
PhaseOffset
NumDitherBits
NumQuantizerAccumulatorBits
Waveform
SamplesPerFrame
RoundingMethod
OverflowAction
AccumulatorDataType
CustomAccumulatorDataType
OutputDataType
CustomOutputDataType
Dither
PhaseQuantization
PhaseQuantizationErrorOutputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=NCO(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.NCO.propListManager');
            coder.extrinsic('dspcodegen.NCO.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.NCO(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.NCO.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.NCO.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'PhaseIncrementSource',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'PhaseIncrementSource'));
                obj.PhaseIncrementSource=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'PhaseIncrement',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'PhaseIncrement'));
                obj.PhaseIncrement=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'PhaseOffsetSource',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'PhaseOffsetSource'));
                obj.PhaseOffsetSource=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'PhaseOffset',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'PhaseOffset'));
                obj.PhaseOffset=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'NumDitherBits',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'NumDitherBits'));
                obj.NumDitherBits=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'NumQuantizerAccumulatorBits',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'NumQuantizerAccumulatorBits'));
                obj.NumQuantizerAccumulatorBits=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'Waveform',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'Waveform'));
                obj.Waveform=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'SamplesPerFrame',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'SamplesPerFrame'));
                obj.SamplesPerFrame=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'AccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'AccumulatorDataType'));
                obj.AccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'CustomAccumulatorDataType',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'CustomAccumulatorDataType'));
                obj.CustomAccumulatorDataType=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'Dither',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'Dither'));
                obj.Dither=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'PhaseQuantization',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'PhaseQuantization'));
                obj.PhaseQuantization=val;
            end
            if~coder.internal.const(dspcodegen.NCO.propListManager(s,'PhaseQuantizationErrorOutputPort',false))
                val=coder.internal.const(dspcodegen.NCO.getFieldFromMxStruct(propValues,'PhaseQuantizationErrorOutputPort'));
                obj.PhaseQuantizationErrorOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.PhaseIncrementSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseIncrementSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.PhaseIncrementSource=val;
        end
        function set.PhaseIncrement(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseIncrement),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.PhaseIncrement=val;
        end
        function set.PhaseOffsetSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseOffsetSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.PhaseOffsetSource=val;
        end
        function set.PhaseOffset(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseOffset),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.PhaseOffset=val;
        end
        function set.NumDitherBits(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumDitherBits),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.NumDitherBits=val;
        end
        function set.NumQuantizerAccumulatorBits(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumQuantizerAccumulatorBits),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.NumQuantizerAccumulatorBits=val;
        end
        function set.Waveform(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Waveform),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.Waveform=val;
        end
        function set.SamplesPerFrame(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerFrame),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.SamplesPerFrame=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.OverflowAction=val;
        end
        function set.AccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.AccumulatorDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomAccumulatorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.CustomAccumulatorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.CustomOutputDataType=val;
        end
        function set.Dither(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Dither),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.Dither=val;
        end
        function set.PhaseQuantization(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseQuantization),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.PhaseQuantization=val;
        end
        function set.PhaseQuantizationErrorOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PhaseQuantizationErrorOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.NCO');
            obj.PhaseQuantizationErrorOutputPort=val;
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
            result='dsp.NCO';
        end
    end
end
