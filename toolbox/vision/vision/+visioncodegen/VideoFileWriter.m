classdef VideoFileWriter<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Filename
FileFormat
AudioCompressor
VideoCompressor
FrameRate
AudioDataType
FileColorSpace
Quality
CompressionFactor
AudioInputPort
AudioInputPortActive
AudioCompressorActive
VideoCompressorActive
FileColorSpaceActive
QualityActive
CompressionFactorActive
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=VideoFileWriter(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.VideoFileWriter.propListManager');
            coder.extrinsic('visioncodegen.VideoFileWriter.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.VideoFileWriter(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Filename');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=visioncodegen.VideoFileWriter.propListManager(numValueOnlyProps,'Filename');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.VideoFileWriter.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'Filename',false))
                val=coder.internal.const(visioncodegen.VideoFileWriter.getFieldFromMxStruct(propValues,'Filename'));
                obj.Filename=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'FileFormat',false))
                val=coder.internal.const(visioncodegen.VideoFileWriter.getFieldFromMxStruct(propValues,'FileFormat'));
                obj.FileFormat=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'AudioCompressor',false))
                val=coder.internal.const(visioncodegen.VideoFileWriter.getFieldFromMxStruct(propValues,'AudioCompressor'));
                obj.AudioCompressor=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'VideoCompressor',false))
                val=coder.internal.const(visioncodegen.VideoFileWriter.getFieldFromMxStruct(propValues,'VideoCompressor'));
                obj.VideoCompressor=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'FrameRate',false))
                val=coder.internal.const(visioncodegen.VideoFileWriter.getFieldFromMxStruct(propValues,'FrameRate'));
                obj.FrameRate=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'AudioDataType',false))
                val=coder.internal.const(visioncodegen.VideoFileWriter.getFieldFromMxStruct(propValues,'AudioDataType'));
                obj.AudioDataType=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'FileColorSpace',false))
                val=coder.internal.const(visioncodegen.VideoFileWriter.getFieldFromMxStruct(propValues,'FileColorSpace'));
                obj.FileColorSpace=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'Quality',false))
                val=coder.internal.const(visioncodegen.VideoFileWriter.getFieldFromMxStruct(propValues,'Quality'));
                obj.Quality=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'CompressionFactor',false))
                val=coder.internal.const(visioncodegen.VideoFileWriter.getFieldFromMxStruct(propValues,'CompressionFactor'));
                obj.CompressionFactor=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'AudioInputPort',false))
                val=coder.internal.const(visioncodegen.VideoFileWriter.getFieldFromMxStruct(propValues,'AudioInputPort'));
                obj.AudioInputPort=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'AudioInputPortActive',false))
                val=coder.internal.const(get(obj.cSFunObject,'AudioInputPortActive'));
                obj.AudioInputPortActive=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'AudioCompressorActive',false))
                val=coder.internal.const(get(obj.cSFunObject,'AudioCompressorActive'));
                obj.AudioCompressorActive=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'VideoCompressorActive',false))
                val=coder.internal.const(get(obj.cSFunObject,'VideoCompressorActive'));
                obj.VideoCompressorActive=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'FileColorSpaceActive',false))
                val=coder.internal.const(get(obj.cSFunObject,'FileColorSpaceActive'));
                obj.FileColorSpaceActive=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'QualityActive',false))
                val=coder.internal.const(get(obj.cSFunObject,'QualityActive'));
                obj.QualityActive=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileWriter.propListManager(s,'CompressionFactorActive',false))
                val=coder.internal.const(get(obj.cSFunObject,'CompressionFactorActive'));
                obj.CompressionFactorActive=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Filename(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Filename),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileWriter');
            obj.Filename=val;
        end
        function set.FileFormat(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FileFormat),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileWriter');
            obj.FileFormat=val;
        end
        function set.AudioCompressor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AudioCompressor),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileWriter');
            obj.AudioCompressor=val;
        end
        function set.VideoCompressor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VideoCompressor),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileWriter');
            obj.VideoCompressor=val;
        end
        function set.FrameRate(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FrameRate),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileWriter');
            obj.FrameRate=val;
        end
        function set.AudioDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AudioDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileWriter');
            obj.AudioDataType=val;
        end
        function set.FileColorSpace(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FileColorSpace),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileWriter');
            obj.FileColorSpace=val;
        end
        function set.Quality(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Quality),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileWriter');
            obj.Quality=val;
        end
        function set.CompressionFactor(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CompressionFactor),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileWriter');
            obj.CompressionFactor=val;
        end
        function set.AudioInputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AudioInputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileWriter');
            obj.AudioInputPort=val;
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
            result='vision.VideoFileWriter';
        end
    end
end
