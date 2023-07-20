classdef AudioFileReader<matlab.System&matlab.system.mixin.FiniteSource
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
FilenameIsTunableInCodegen
CodegenPrototypeFile
PlayCount
SamplesPerFrame
OutputDataType
ReadRange
privFilenameLen
    end
    properties(Dependent)
Filename
    end
    properties(Hidden)
        privFilename=[uint16(dsp.AudioFileReader.getFilePath('speech_dft.mp3')),zeros(1,1000-59)]
    end
    properties(SetAccess=private,Nontunable,Dependent)
SampleRate
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=AudioFileReader(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.AudioFileReader.propListManager');
            coder.extrinsic('dspcodegen.AudioFileReader.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.AudioFileReader(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Filename');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=dspcodegen.AudioFileReader.propListManager(numValueOnlyProps,'Filename');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.AudioFileReader.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.AudioFileReader.propListManager(s,'FilenameIsTunableInCodegen',false))
                val=coder.internal.const(dspcodegen.AudioFileReader.getFieldFromMxStruct(propValues,'FilenameIsTunableInCodegen'));
                obj.FilenameIsTunableInCodegen=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileReader.propListManager(s,'CodegenPrototypeFile',false))
                val=coder.internal.const(dspcodegen.AudioFileReader.getFieldFromMxStruct(propValues,'CodegenPrototypeFile'));
                obj.CodegenPrototypeFile=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileReader.propListManager(s,'PlayCount',false))
                val=coder.internal.const(dspcodegen.AudioFileReader.getFieldFromMxStruct(propValues,'PlayCount'));
                obj.PlayCount=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileReader.propListManager(s,'SamplesPerFrame',false))
                val=coder.internal.const(dspcodegen.AudioFileReader.getFieldFromMxStruct(propValues,'SamplesPerFrame'));
                obj.SamplesPerFrame=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileReader.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.AudioFileReader.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileReader.propListManager(s,'ReadRange',false))
                val=coder.internal.const(dspcodegen.AudioFileReader.getFieldFromMxStruct(propValues,'ReadRange'));
                obj.ReadRange=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileReader.propListManager(s,'Filename',false))
                val=coder.internal.const(dspcodegen.AudioFileReader.getFieldFromMxStruct(propValues,'Filename'));
                obj.Filename=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileReader.propListManager(s,'privFilenameLen',false))
                val=coder.internal.const(get(obj.cSFunObject,'privFilenameLen'));
                obj.privFilenameLen=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileReader.propListManager(s,'privFilename',false))
                val=coder.internal.const(get(obj.cSFunObject,'privFilename'));
                obj.privFilename=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Filename(obj,val)
            coder.inline('always');
            coder.extrinsic('dsp.AudioFileReader.getFilePath');
            if~obj.cSFunObject.FilenameIsTunableInCodegen
                value=coder.const(@dsp.AudioFileReader.getFilePath,char(val));
            else
                value=char(val);
            end
            obj.privFilename(1:length(value))=uint16(value);
            obj.privFilename(length(value)+1:end)=0;
        end
        function set.privFilename(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'privFilename',val,noTuningError);%#ok<MCSUP>
            obj.privFilename=val;
        end
        function val=get.SampleRate(obj)
            val=get(obj.cSFunObject,'SampleRate');
        end
        function set.FilenameIsTunableInCodegen(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FilenameIsTunableInCodegen),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.AudioFileReader');
            obj.FilenameIsTunableInCodegen=val;
        end
        function set.CodegenPrototypeFile(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CodegenPrototypeFile),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.AudioFileReader');
            obj.CodegenPrototypeFile=val;
        end
        function set.PlayCount(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PlayCount),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.AudioFileReader');
            obj.PlayCount=val;
        end
        function set.SamplesPerFrame(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SamplesPerFrame),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.AudioFileReader');
            obj.SamplesPerFrame=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.AudioFileReader');
            obj.OutputDataType=val;
        end
        function set.ReadRange(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ReadRange),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.AudioFileReader');
            obj.ReadRange=val;
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
        function releaseImpl(obj)
            release(obj.cSFunObject);
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
        function y=isDoneImpl(obj)
            y=isDone(obj.cSFunObject);
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
            result='dsp.AudioFileReader';
        end
    end
end
