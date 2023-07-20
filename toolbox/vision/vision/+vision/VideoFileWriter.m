classdef VideoFileWriter<matlab.system.SFunSystem

















































































%#function mdspwmmfo2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        Filename='output.avi';














        FileFormat='AVI';












        AudioCompressor='None (uncompressed)';










        VideoCompressor='None (uncompressed)';










        FrameRate=30;







        AudioDataType='int16';




        FileColorSpace='RGB';










        Quality=75;








        CompressionFactor=10;




        AudioInputPort(1,1)logical=false;
    end

    properties(Nontunable,Hidden,Dependent)
        AudioInputPortActive;
        AudioCompressorActive;
        VideoCompressorActive;
        FileColorSpaceActive;
        QualityActive;
        CompressionFactorActive;
    end

    properties(Constant,Hidden)
        AudioCompressorSet=matlab.system.StringSet(getDefaultSupportedAudioCompressors());
        FileFormatSet=matlab.system.StringSet(getSupportedFileFormats());
        AudioDataTypeSet=matlab.system.StringSet({'inherit','uint8','int16','int24','single'});
    end

    properties(Hidden)
        FileColorSpaceSet=matlab.system.internal.DynamicStringSet(getDefaultSupportedFileColorSpace());
        VideoCompressorSet=matlab.system.internal.DynamicStringSet(getDefaultSupportedVideoCompressors());
    end

    methods

        function obj=VideoFileWriter(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspwmmfo2');
            obj.VideoCompressorSet=matlab.system.internal.DynamicStringSet(getDefaultSupportedVideoCompressors());
            obj.FileColorSpaceSet=matlab.system.internal.DynamicStringSet(getDefaultSupportedFileColorSpace());
            setProperties(obj,nargin,varargin{:},'Filename');
            if isstring(obj.Filename)
                obj.Filename=convertStringsToChars(obj.Filename);
            end
            setVarSizeAllowedStatus(obj,false);
        end
    end


    methods
        function set.FileFormat(obj,aFormat)
            obj.FileFormat=findMatch(obj.FileFormatSet,aFormat);
            updateFileFormatDependentStringSets(obj);
        end

        function set.FrameRate(obj,value)
            validateattributes(value,{'numeric'},...
            {'positive','finite','scalar'},'','FrameRate');
            obj.FrameRate=value;
        end
    end

    methods(Access=private)
        function updateFileFormatDependentStringSets(obj)
            fileTypeInfo=dspFileTypeInfoToMultimediaFile(obj.FileFormat);

            if~isempty(fileTypeInfo.VideoCompressors)&&~isscalar(fileTypeInfo.VideoCompressors)
                changeValues(obj.VideoCompressorSet,fileTypeInfo.VideoCompressors,obj,...
                'VideoCompressor',fileTypeInfo.DefaultVideoCompressor);
            end

            if~isempty(fileTypeInfo.FileColorFormats)&&~isscalar(fileTypeInfo.FileColorFormats)
                changeValues(obj.FileColorSpaceSet,fileTypeInfo.FileColorFormats,obj,...
                'FileColorSpace',fileTypeInfo.DefaultFileColorFormat);
            end
        end
    end


    methods
        function val=get.AudioInputPort(obj)
            if obj.AudioInputPortActive
                val=obj.AudioInputPort;
            else
                val=false;
            end
        end

        function val=get.AudioCompressor(obj)
            if obj.AudioCompressorActive
                val=obj.AudioCompressor;
            else
                val='None (uncompressed)';
            end
        end

        function val=get.VideoCompressor(obj)
            if obj.VideoCompressorActive
                val=obj.VideoCompressor;
            else
                val='None (uncompressed)';
            end
        end

        function val=get.FileColorSpace(obj)
            if obj.FileColorSpaceActive
                val=obj.FileColorSpace;
            else
                val='RGB';
            end
        end
    end

    methods(Access='protected')
        function validateInputsImpl(obj,varargin)



            if obj.AudioInputPort&&(nargin~=3&&nargin~=5)
                error(message('vision:VideoFileWriter:incorrectNumComponents'));
            end



            if nargin==4||nargin==5
                if strcmp(obj.FileColorSpace,'RGB')&&~isDimsCorrectForRGB(varargin{1:3})
                    error(message('vision:VideoFileWriter:incorrectDataDims',obj.FileColorSpace));
                end

                if strcmp(obj.FileColorSpace,'YCbCr 4:2:2')&&~isDimsCorrectForYCbCbr(varargin{1:3})
                    error(message('vision:VideoFileWriter:incorrectDataDims',obj.FileColorSpace));
                end
            end
        end
    end
    methods(Hidden)
        function setParameters(obj)

            isStream=(strcmpi(obj.Filename(1:4),'mms:')||...
            strcmpi(obj.Filename(1:5),'http:'));

            fileTypeInfo=dspFileTypeInfoToMultimediaFile(obj.FileFormat);
            if(~isStream)
                [~,~,fileExt]=fileparts(obj.Filename);
                validFileFmtAndFileExt=ismember(fileExt,fileTypeInfo.VideoFileExtensions);
                coder.internal.errorIf(~validFileFmtAndFileExt,...
                'vision:system:invalidFileExtFileFormat')
            end


            if obj.AudioInputPort
                streamSelection='Video and audio';
            else
                streamSelection='Video only';
            end

            setSampleTimeIsFramePeriod(obj,false);
            setSampleRate(obj,obj.FrameRate);

            obj.compSetParameters({obj.Filename,...
            0,...
            obj.VideoCompressor,...
            2,...
            obj.AudioCompressor,...
            streamSelection,...
            1,...
            obj.FileFormat,...
            'int16',...
            obj.FileColorSpace,...
            fileTypeInfo.VWPlugins.Device,...
            fileTypeInfo.VWPlugins.Converter,...
            fileTypeInfo.VWPlugins.Filter,...
            obj.Quality,...
            obj.CompressionFactor
            });
        end
        function y=callTerminateAfterCodegen(~)





            y=true;
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)



            propsMap=containers.Map;
            propsMap('Filename')=false;
            propsMap('FileFormat')=false;
            propsMap('FrameRate')=false;
            propsMap('AudioInputPort')=~obj.AudioInputPortActive;
            propsMap('AudioCompressor')=~obj.AudioCompressorActive;
            propsMap('VideoCompressor')=~obj.VideoCompressorActive;
            propsMap('FileColorSpace')=~obj.FileColorSpaceActive;
            propsMap('Quality')=~obj.QualityActive;
            propsMap('CompressionFactor')=~obj.CompressionFactorActive;
            propsMap('AudioDataType')=true;

            mapKeys=keys(propsMap);
            mapVals=values(propsMap,mapKeys);
            mapVals=[mapVals{:}];
            inactiveProps=mapKeys(mapVals);

            flag=ismember(prop,inactiveProps);
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={'Filename'...
            ,'FileFormat'...
            ,'AudioInputPort'...
            ,'FrameRate'...
            ,'AudioCompressor'...
            ,'VideoCompressor'...
            ,'FileColorSpace'...
            ,'AudioDataType'...
            ,'Quality'...
            ,'CompressionFactor'...
            };
        end



        function props=getValueOnlyProperties()
            props={'Filename'};
        end
    end

    methods(Sealed,Hidden)
        function close(obj)




            warning(message('MATLAB:system:throwObsoleteMethodWarningNewName',...
            class(obj),'close','release'));
            release(obj);
        end
    end

    methods
        function isActive=get.AudioInputPortActive(obj)
            fileTypeInfo=dspFileTypeInfoToMultimediaFile(obj.FileFormat);


            isActive=ismember('Video and audio',fileTypeInfo.AllWriteableStreams);



            if~ispc
                isActive=isActive&&...
                ~(strcmp(obj.FileFormat,'AVI')&&...
                strcmp(obj.VideoCompressor,'MJPEG Compressor'));
            end

        end

        function isActive=get.AudioCompressorActive(obj)


            if~obj.AudioInputPort
                isActive=false;
                return;
            end

            fileTypeInfo=dspFileTypeInfoToMultimediaFile(obj.FileFormat);



            isActive=ismember('Video and audio',fileTypeInfo.AllWriteableStreams)&&...
            ~isempty(fileTypeInfo.AudioCompressors);



            if~ispc
                isActive=isActive||...
                ~(strcmp(obj.FileFormat,'AVI')&&...
                strcmp(obj.VideoCompressor,'MJPEG Compressor'));
            end
        end

        function isActive=get.VideoCompressorActive(obj)
            fileTypeInfo=dspFileTypeInfoToMultimediaFile(obj.FileFormat);



            isActive=any(strncmp('Video',fileTypeInfo.AllWriteableStreams,5))&&...
            ~isempty(fileTypeInfo.VideoCompressors);
        end

        function isActive=get.FileColorSpaceActive(obj)
            fileTypeInfo=dspFileTypeInfoToMultimediaFile(obj.FileFormat);



            isActive=any(strncmp('Video',fileTypeInfo.AllWriteableStreams,5))&&...
            (~isempty(fileTypeInfo.FileColorFormats)&&...
            ~isscalar(fileTypeInfo.FileColorFormats));
        end

        function isActive=get.QualityActive(obj)

            isActive=(strcmp(obj.FileFormat,'MPEG4')&&~obj.AudioInputPort);



            if~ispc
                isActive=isActive||...
                (strcmp(obj.FileFormat,'AVI')&&...
                strcmp(obj.VideoCompressor,'MJPEG Compressor')&&...
                ~obj.AudioInputPort);
            end
        end

        function isActive=get.CompressionFactorActive(obj)
            isActive=strcmp(obj.FileFormat,'MJ2000')&&strcmp(obj.VideoCompressor,'Lossy');
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionsources/To Multimedia File';
        end
    end
end

function fileTypes=getSupportedFileFormats()


    fileTypes=dspFileTypesToMultimediaFile;
    supportsVideo=false(size(fileTypes));

    for cnt=1:numel(fileTypes)
        fileTypeInfo=dspFileTypeInfoToMultimediaFile(fileTypes{cnt});
        supportsVideo(cnt)=any(cellfun(@(x)~isempty(strfind(x,'Video')),...
        fileTypeInfo.AllWriteableStreams));
    end
    fileTypes=fileTypes(supportsVideo);

end

function videoComps=getDefaultSupportedVideoCompressors()

    fileTypeInfo=dspFileTypeInfoToMultimediaFile('AVI');
    videoComps=fileTypeInfo.VideoCompressors;
end

function audioComps=getDefaultSupportedAudioCompressors()

    fileTypeInfo=dspFileTypeInfoToMultimediaFile('AVI');
    audioComps=fileTypeInfo.VideoCompressors;

end

function fileColorSpace=getDefaultSupportedFileColorSpace()

    fileTypeInfo=dspFileTypeInfoToMultimediaFile('AVI');
    fileColorSpace=fileTypeInfo.FileColorFormats;

end

function isDimsCorrect=isDimsCorrectForRGB(r,g,b)
    isDimsCorrect=(size(r,3)==1)&&...
    isequal(size(r),size(g),size(b));
end

function isDimsCorrect=isDimsCorrectForYCbCbr(y,cb,cr)
    isDimsCorrect=size(y,3)==1&&...
    size(y,2)==2*size(cb,2)&&...
    all(size(cb)==size(cr));
end
