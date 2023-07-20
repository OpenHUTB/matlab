classdef AudioFileWriter<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
FileFormat
SampleRate
Compressor
DataType
privFilenameLen
    end
    properties(Dependent)
Filename
    end
    properties(Hidden)
        privFilename=[uint16('output.wav'),zeros(1,990)];
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=AudioFileWriter(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.AudioFileWriter.propListManager');
            coder.extrinsic('dspcodegen.AudioFileWriter.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.AudioFileWriter(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Filename');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=dspcodegen.AudioFileWriter.propListManager(numValueOnlyProps,'Filename');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.AudioFileWriter.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.AudioFileWriter.propListManager(s,'FileFormat',false))
                val=coder.internal.const(dspcodegen.AudioFileWriter.getFieldFromMxStruct(propValues,'FileFormat'));
                obj.FileFormat=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileWriter.propListManager(s,'SampleRate',false))
                val=coder.internal.const(dspcodegen.AudioFileWriter.getFieldFromMxStruct(propValues,'SampleRate'));
                obj.SampleRate=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileWriter.propListManager(s,'Compressor',false))
                val=coder.internal.const(dspcodegen.AudioFileWriter.getFieldFromMxStruct(propValues,'Compressor'));
                obj.Compressor=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileWriter.propListManager(s,'DataType',false))
                val=coder.internal.const(dspcodegen.AudioFileWriter.getFieldFromMxStruct(propValues,'DataType'));
                obj.DataType=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileWriter.propListManager(s,'Filename',false))
                val=coder.internal.const(dspcodegen.AudioFileWriter.getFieldFromMxStruct(propValues,'Filename'));
                obj.Filename=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileWriter.propListManager(s,'privFilenameLen',false))
                val=coder.internal.const(get(obj.cSFunObject,'privFilenameLen'));
                obj.privFilenameLen=val;
            end
            if~coder.internal.const(dspcodegen.AudioFileWriter.propListManager(s,'privFilename',false))
                val=coder.internal.const(get(obj.cSFunObject,'privFilename'));
                obj.privFilename=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Filename(obj,val)
            coder.inline('always');
            value=char(val);
            obj.privFilename(1:length(value))=uint16(value);
            obj.privFilename(length(value)+1:end)=0;
        end
        function set.privFilename(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'privFilename',val,noTuningError);%#ok<MCSUP>
            obj.privFilename=val;
        end
        function set.FileFormat(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FileFormat),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.AudioFileWriter');
            obj.FileFormat=val;
        end
        function set.SampleRate(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SampleRate),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.AudioFileWriter');
            obj.SampleRate=val;
        end
        function set.Compressor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Compressor),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.AudioFileWriter');
            obj.Compressor=val;
        end
        function set.DataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.AudioFileWriter');
            obj.DataType=val;
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
            result='dsp.AudioFileWriter';
        end
    end
end
