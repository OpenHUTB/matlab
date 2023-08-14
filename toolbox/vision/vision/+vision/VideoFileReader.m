classdef VideoFileReader<matlab.system.SFunSystem&...
    matlab.system.mixin.FiniteSource















































































%#function mdspwmmfi2

    properties(Nontunable)





        Filename='vipmen.avi';



        PlayCount=1;





        ImageColorSpace='RGB';






        VideoOutputDataType='single';





        AudioOutputDataType='int16';






        AudioOutputPort(1,1)logical=false;
    end

    properties(Access=protected,Nontunable)
        pHasAudio=false;
    end

    properties(Constant,Hidden,Nontunable)

        AudioOutputDataTypeSet=matlab.system.StringSet({...
        'double','single','int16','uint8'});
        VideoOutputDataTypeSet=matlab.system.StringSet({...
        'double','single','int8','uint8','int16','uint16',...
        'int32','uint32','Inherit'});
        ImageColorSpaceSet=matlab.system.StringSet({'RGB','Intensity','YCbCr 4:2:2'});
    end

    methods
        function obj=VideoFileReader(varargin)
            if nargin>0
                [varargin{:}]=convertStringsToChars(varargin{:});
            end
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspwmmfi2');
            setProperties(obj,length(varargin),varargin{:},'Filename');
            if strcmp(get(obj,'Filename'),'vipmen.avi')

                set(obj,'Filename','vipmen.avi');
            end
        end

        function set.Filename(obj,value)
            validateattributes(value,{'char'},{'nonempty'},'','Filename');
            theFile=which(value);
            if isempty(theFile)
                theFile=value;
            end

            previousFilename=obj.Filename;
            obj.Filename=theFile;
            try
                setFileInfoProps(obj);
            catch err
                obj.Filename=previousFilename;
                rethrow(err);
            end
        end

        function set.AudioOutputPort(obj,value)
            obj.AudioOutputPort=value;
            if~ispc
                if(value)
                    fileinfo=dspvideofileinfo(obj.Filename);%#ok<MCSUP>
                    if(fileinfo.hasAudio&&fileinfo.isAudioCompressed)
                        warning(message('vision:VideoFileReader:compAudioNotSupported'));
                    elseif fileinfo.useMMReader


                        warning(message('vision:VideoFileReader:audioNotSupported'));
                    end
                end
            end
        end

    end

    methods(Access=protected)
        function status=isDoneImpl(obj)







            if isLocked(obj)
                status=lastOutput(obj,int32(getNumOutputs(obj)));
            else
                status=false;
            end
        end
        function s=infoImpl(obj)




































            fileinfo=dspvideofileinfo(obj.Filename);
            s.Audio=fileinfo.hasAudio;
            s.Video=fileinfo.hasVideo;
            if s.Audio
                s.AudioSampleRate=fileinfo.audioSampleRate;
                s.AudioNumBits=fileinfo.audioNumBits;
                s.AudioNumChannels=fileinfo.audioNumChannels;
            end
            if s.Video
                s.VideoFrameRate=fileinfo.videoFPSComputed;
                s.VideoSize=[fileinfo.videoWidthInPixels,fileinfo.videoHeightInPixels];
                s.VideoFormat=fileinfo.videoFormat;
            end
        end
    end

    methods(Access=protected)
        function loadObjectImpl(obj,s,~)
            try
                obj.Filename=s.Filename;
            catch Err %#ok<NASGU>

                warning(message('vision:VideoFileReader:invalidInputFile'));
            end
            s=rmfield(s,'Filename');
            set(obj,s);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            fileInfo=dspvideofileinfo(obj.Filename);
            pluginPath='';
            converterPath='';
            if fileInfo.useMMReader
                pluginPath=fileInfo.videoPluginPath;
                converterPath=fileInfo.videoConverterPath;
            end
            if obj.shouldOutputAudio()
                pSamplesPerAudioFrame=...
                ceil(fileInfo.audioSampleRate/fileInfo.videoFramesPerSecond);
            else
                pSamplesPerAudioFrame=0;
            end

            videoOutputDataType=obj.VideoOutputDataType;
            if strcmp(videoOutputDataType,'Inherit')
                videoOutputDataType='Inherit from file';
            end

            isLooping=double(any(obj.PlayCount~=1));

            obj.compSetParameters({...
            obj.Filename,...
            0,...
            '',...
            fileInfo,...
            videoOutputDataType,...
            1,...
            obj.AudioOutputDataType,...
            obj.getOutputStreams(),...
            isLooping,...
            obj.PlayCount,...
            1,...
            1,...
            double(false),...
            obj.ImageColorSpace,...
            double(true),...
            double(true),...
            1,...
            pSamplesPerAudioFrame,...
            pluginPath,...
            1,...
            converterPath,...
            1,...
            intmax('int64')
            });
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~isempty(which(obj.Filename))
                if~obj.shouldOutputAudio()
                    props{end+1}='AudioOutputDataType';
                end
                if~obj.canOutputAudio()
                    props{end+1}='AudioOutputPort';
                end
            end
            flag=ismember(prop,props);
        end

        function val=canOutputAudio(obj)
            fileinfo=dspvideofileinfo(obj.Filename);
            if ispc
                val=fileinfo.hasAudio;
            else
                if(fileinfo.hasAudio&&fileinfo.isAudioCompressed)||...
                    (fileinfo.useMMReader)
                    val=false;
                else
                    val=fileinfo.hasAudio;
                end
            end
        end

        function val=shouldOutputAudio(obj)
            val=canOutputAudio(obj)&&obj.AudioOutputPort;
        end

        function val=canOutputVideo(obj)
            fileinfo=dspvideofileinfo(obj.Filename);
            val=fileinfo.hasVideo;
        end

        function val=getOutputStreams(obj)
            if obj.shouldOutputAudio()
                val='Video and audio';
            else
                val='Video only';
            end
        end

        function fileinfo=setFileInfoProps(obj)
            try
                fileinfo=dspvideofileinfo(obj.Filename);
            catch
                try
                    fileinfoAudio=dspaudiofileinfo(obj.Filename);
                    hasAudio=fileinfoAudio.hasAudio;
                catch
                    hasAudio=false;
                end
                if hasAudio
                    coder.internal.errorIf(true,'vision:VideoFileReader:audioOnly');
                else
                    coder.internal.errorIf(true,'vision:VideoFileReader:invalidInputFile');
                end
            end
            obj.pHasAudio=fileinfo.hasAudio;
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
            'Filename',...
            'PlayCount',...
            'AudioOutputPort',...
            'ImageColorSpace',...
            'AudioOutputDataType',...
'VideoOutputDataType'
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

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionsources/From Multimedia File';
        end
    end

    methods(Access=public,Static,Hidden)

        function eofport=isEOFPortAvailable(~)
            eofport=true;
        end
    end

end

