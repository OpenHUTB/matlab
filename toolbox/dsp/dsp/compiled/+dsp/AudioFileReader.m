classdef AudioFileReader<matlab.system.SFunSystem&...
    matlab.system.mixin.FiniteSource


































































%#function mdspwmmfi2

    properties(Dependent)





Filename
    end

    properties(Hidden)
        privFilename=[uint16(dsp.AudioFileReader.getFilePath('speech_dft.mp3')),zeros(1,1000-59)];
        privFilenameLen=length(dsp.AudioFileReader.getFilePath('speech_dft.mp3'));
    end

    properties(Nontunable)




        FilenameIsTunableInCodegen=false;








        CodegenPrototypeFile=dsp.AudioFileReader.getFilePath('speech_dft.mp3')



        PlayCount=1;



        SamplesPerFrame=1024;




        OutputDataType='double';





        ReadRange{mustBeNumeric}=[1,Inf];
    end

    properties(SetAccess=private,Dependent,Nontunable)



        SampleRate;
    end

    properties(Constant,Hidden)

        OutputDataTypeSet=matlab.system.StringSet({...
        'double','single','int16','uint8'});
    end

    methods
        function obj=AudioFileReader(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspwmmfi2');
            setProperties(obj,length(varargin),varargin{:},'Filename');
            if strcmp(get(obj,'Filename'),'speech_dft.mp3')

                set(obj,'Filename','speech_dft.mp3');
            end
        end

        function set.FilenameIsTunableInCodegen(obj,value)
            validateattributes(value,{'numeric','logical'},{'nonempty','scalar','finite','real'},'','FilenameIsTunableInCodegen');
            obj.FilenameIsTunableInCodegen=value;
        end

        function set.CodegenPrototypeFile(obj,value)
            validateattributes(value,{'char','string'},{'nonempty'},'','Filename');
            theFile=which(char(value));
            if isempty(theFile)
                theFile=value;
            end

            previousFilename=obj.CodegenPrototypeFile;
            obj.CodegenPrototypeFile=theFile;
            try

                setFileInfoProps(obj);
            catch err
                obj.CodegenPrototypeFile=previousFilename;
                rethrow(err);
            end
        end

        function set.Filename(obj,val)
            validateattributes(val,{'char','string'},{'nonempty'},'','Filename');
            if obj.FilenameIsTunableInCodegen
                validateattributes(numel(val),{'numeric'},{'scalar','<=',1000},'','length(Filename)');
            end


            previousFilename=obj.Filename;

            value=char(val);
            if obj.FilenameIsTunableInCodegen
                coder.internal.errorIf(~strncmpi(value,'http:',5)&&isempty(dir(value)),'dsp:system:AudioFileReader:FileDoesNotExist');
                fullFilename=value;
            else
                fullFilename=dsp.AudioFileReader.getFilePath(value);
            end

            obj.privFilename(1:length(fullFilename))=uint16(fullFilename);
            obj.privFilename(length(fullFilename)+1:end)=0;
            obj.privFilenameLen=length(fullFilename);

            try

                setFileInfoProps(obj);
            catch err
                value=char(previousFilename);
                obj.privFilenameLen=length(value);
                fullFilename=dsp.AudioFileReader.getFilePath(value);
                obj.privFilename(1:length(fullFilename))=uint16(fullFilename);
                obj.privFilename(length(fullFilename)+1:end)=0;

                rethrow(err);
            end
        end

        function val=get.Filename(obj)
            val=char(obj.privFilename(1:obj.privFilenameLen));
        end

        function set.ReadRange(obj,val)
            validateattributes(...
            val,{'numeric'},...
            {'positive','nonempty','nonnan',...
            'nondecreasing','ncols',2,'nrows',1});

            validateattributes(...
            val(1),{'numeric'},...
            {'integer'});

            if(val(2)~=inf)
                validateattributes(...
                val(2),{'numeric'},...
                {'integer'});
            end

            obj.ReadRange=val;
        end

        function fs=get.SampleRate(obj)
            s=dspaudiofileinfo(obj.getFileAbsolutePath());
            if s.hasAudio
                fs=s.audioSampleRate;
            else
                fs=[];
            end
        end
    end

    methods(Access=protected)

        function val=isInactivePropertyImpl(obj,prop)
            val=false;
            if strcmp(prop,'CodegenPrototypeFile')
                val=~obj.FilenameIsTunableInCodegen;
            end
        end

        function status=isDoneImpl(obj)








            status=lastOutput(obj,int32(getNumOutputs(obj)));
        end

        function s=infoImpl(obj)










            fileinfo=dspaudiofileinfo(obj.getFileAbsolutePath());
            s=struct('SampleRate',[],'NumBits',[],'NumChannels',[]);
            if fileinfo.hasAudio
                s.SampleRate=fileinfo.audioSampleRate;
                s.NumBits=fileinfo.audioBitsPerSample;
                s.NumChannels=fileinfo.audioNumChannels;
            end
        end

        function loadObjectImpl(obj,s,~)
            try
                if isfield(s,'privFilename')
                    obj.Filename=char(s.privFilename(1:s.privFilenameLen));
                else
                    obj.Filename=s.Filename;
                end

            catch Err



                warning(Err.identifier,regexprep(Err.message,'\','\\\'));

                if isfield(s,'privFilename')
                    s=rmfield(s,'privFilename');
                    s=rmfield(s,'privFilenameLen');
                else
                    s=rmfield(s,'Filename');
                end
            end
            set(obj,s);
        end

        function browseButtonCallback(obj)


            if(exist(obj.Filename,'file'))
                currFile=which(obj.Filename);
            else
                currFile=obj.Filename;
            end

            audioFilesTitle=getString(message('dsp:system:AudioFileReader:AudioFiles'));
            allFilesTitle=getString(message('dsp:system:AudioFileReader:AllFiles'));
            dialogTitle=getString(message('dsp:system:AudioFileReader:SelectAudioFile'));

            audioFileExts=dsp.AudioFileReader.getSupportedFileExtensions();
            audioFileFormats=strcat(cellstr(repmat('*',numel(audioFileExts),1)),...
            audioFileExts(:),cellstr(repmat(';',numel(audioFileExts),1)));
            audioFileFormats=strcat(audioFileFormats{:});
            audioFileFormatsTitle=' (*.wav,*.flac,*.ogg,*.aif,*.mp3,*.m4a ...)';
            filterSpec={audioFileFormats,[audioFilesTitle,audioFileFormatsTitle];...
            '*.*',[allFilesTitle,' (*.*)']};
            [filename,pathname]=uigetfile(filterSpec,dialogTitle,currFile);


            if filename

                fname=fullfile(pathname,filename);
                obj.Filename=fname;

                dlgs=find(DAStudio.ToolRoot.getOpenDialogs,'dialogTag','dsp.AudioFileReader');
                for idx=1:length(dlgs)
                    currDlg=dlgs(idx);
                    if isa(dlgs(idx),'DAStudio.Dialog')&&(obj==currDlg.getDialogSource.Platform.getSystemHandle)
                        setWidgetValue(currDlg,'Filename',obj.Filename);
                        refresh(currDlg);
                    end
                end
            end
        end

    end

    methods(Hidden)
        function setParameters(obj)

            import multimedia.internal.audio.file.PluginManager;
            pluginDir='';
            converterPath='';

            fileInfo=dspaudiofileinfo(obj.getFileAbsolutePath());
            pSamplesPerFrame=obj.SamplesPerFrame;
            videoOutputDataType='Inherit from file';
            isLooping=double(any(obj.PlayCount~=1));
            startSample=obj.ReadRange(1);
            endSample=obj.ReadRange(2);
            if isinf(endSample)
                endSample=intmax('int64');
            end

            if fileInfo.useMMReader&&fileInfo.hasAudio
                pluginDir=fileInfo.audioPluginPath;
                converterPath=PluginManager.getInstance.SLConverter;
            end

            if obj.FilenameIsTunableInCodegen
                fname=obj.privFilename;
            else
                fname=char(obj.privFilename);
            end

            obj.compSetParameters({...
            fname,...
            double(obj.FilenameIsTunableInCodegen),...
            obj.CodegenPrototypeFile,...
            fileInfo,...
            videoOutputDataType,...
            1,...
            obj.OutputDataType,...
            'Audio only',...
            isLooping,...
            obj.PlayCount,...
            1,...
            1,...
            double(false),...
            'RGB',...
            double(true),...
            double(true),...
            1,...
            pSamplesPerFrame,...
            pluginDir,...
            1,...
            converterPath,...
            startSample,...
endSample
            });
        end

    end

    methods(Access=protected)
        function[fileinfo,fullPath]=setFileInfoProps(obj)
            fullPath=obj.getFileAbsolutePath();
            fileinfo=dspaudiofileinfo(fullPath);
        end
    end


    methods(Static,Hidden)

        function props=getDisplayPropertiesImpl()
            props={...
            'Filename',...
            'PlayCount',...
            'SamplesPerFrame',...
            'OutputDataType',...
            'FilenameIsTunableInCodegen',...
            'CodegenPrototypeFile',...
            'SampleRate',...
            'ReadRange',...
            };
        end


        function props=getValueOnlyProperties()
            props={'Filename'};
        end

        function exts=getSupportedFileExtensions()




            if ispc
                exts={'.wav','.wma','.avi','.aif','.aifc','.aiff','.mp3',...
                '.au','.snd','.mp4','.m4a','.flac','.ogg','.opus','.mov'};
            else
                if isOpusSupported()
                    exts={'.wav','.avi','.aif','.aifc','.aiff','.mp3',...
                    '.au','.snd','.mp4','.m4a','.flac','.ogg','.opus','.mov'};
                else
                    exts={'.wav','.avi','.aif','.aifc','.aiff','.mp3',...
                    '.au','.snd','.mp4','.m4a','.flac','.ogg','.mov'};
                end
            end
        end

        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.privFilename=0;
        end
    end

    methods(Static,Access=protected)
        function group=getPropertyGroupsImpl

            props=dsp.AudioFileReader.getDisplayPropertiesImpl;
            group=matlab.system.display.Section('PropertyList',props,...
            'DependOnPrivatePropertyList',{'SampleRate'});

            group.Actions=matlab.system.display.Action(@(~,obj)browseButtonCallback(obj),...
            'Label',getString(message('dsp:system:AudioFileReader:Browse')),...
            'Placement','PlayCount','Alignment','right');
        end
    end

    methods(Access=private,Hidden)
        function fullFileName=getFileAbsolutePath(obj)
            if obj.FilenameIsTunableInCodegen
                fullFileName=dsp.AudioFileReader.getFilePath(obj.CodegenPrototypeFile);
            else
                fullFileName=dsp.AudioFileReader.getFilePath(obj.Filename);
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsrcs4/From Multimedia File';
        end
        function fullFileName=getFilePath(fname)
            if strncmpi(fname,'http:',5)
                fileName=strrep(fname,'http:\\','http://');
                fullFileName=fileName;
            else
                fileName=regexprep(fname,'[\/\\]',filesep);

                fullFileName=which(fname);
                if~isempty(fullFileName)
                    return;
                else
                    d=dir(fname);
                    if~isempty(d)
                        fileName=fullfile(d.folder,d.name);
                    end
                end

                [pathStr,baseFile,extProvided]=fileparts(fileName);


                if isempty(pathStr)
                    pathStr=pwd;
                end

                fullFileName=fullfile(pathStr,[baseFile,extProvided]);
            end
        end
    end

    methods(Access=public,Static,Hidden)

        function eofport=isEOFPortAvailable(~)
            eofport=true;
        end
    end
end
