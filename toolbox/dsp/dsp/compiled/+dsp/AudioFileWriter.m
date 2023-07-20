classdef AudioFileWriter<matlab.system.SFunSystem



























































%#function mdspwmmfo2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Dependent)



Filename
    end

    properties(Hidden)
        privFilename=[uint16('output.wav'),zeros(1,990,'uint16')];
        privFilenameLen=10;
    end

    properties(Nontunable)


















        FileFormat='WAV';





        SampleRate=44100;







        Compressor='None (uncompressed)';









        DataType='int16';
    end

    properties(Constant,Hidden)
        CompressorSet=matlab.system.StringSet(...
        dspwin32getcompressornames('audio'));
        FileFormatSet=getSupportedFormatsStringSet()
    end

    properties(Hidden)
        DataTypeSet=matlab.system.internal.DynamicStringSet(...
        {'inherit','uint8','int16','int24','int32','single','double'});
    end

    methods
        function obj=AudioFileWriter(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspwmmfo2');


            obj.DataTypeSet=matlab.system.internal.DynamicStringSet(...
            {'inherit','uint8','int16','int24','int32','single','double'});
            setProperties(obj,nargin,varargin{:},'Filename');
            setVarSizeAllowedStatus(obj,false);
        end

        function set.Filename(obj,val)
            validateattributes(val,{'char','string'},{'nonempty'},'','Filename');
            validateattributes(numel(val),{'numeric'},{'scalar','<=',1000},'','length(Filename)');
            value=char(val);
            obj.privFilename(1:length(value))=uint16(value);
            obj.privFilename(length(value)+1:end)=0;
            obj.privFilenameLen=length(value);
        end

        function val=get.Filename(obj)
            val=char(obj.privFilename(1:obj.privFilenameLen));
        end


        function set.SampleRate(obj,value)
            validateattributes(value,{'numeric'},...
            {'positive','finite','scalar'},...
            '','SampleRate');
            obj.SampleRate=value;
        end

        function set.FileFormat(obj,aFormat)
            obj.FileFormat=aFormat;

            fileTypeInfo=dspFileTypeInfoToMultimediaFile(obj.FileFormat);

            if isempty(fileTypeInfo.AudioDataTypes)
                return;
            end

            if ismember(get(obj,'DataType'),fileTypeInfo.AudioDataTypesForSfun)
                dataTypeVal=get(obj,'DataType');
            else
                dataTypeVal=fileTypeInfo.DefaultAudioDataTypeForSfun;
            end
            changeValues(obj.DataTypeSet,fileTypeInfo.AudioDataTypesForSfun,...
            obj,'DataType',dataTypeVal);%#ok
        end
    end

    methods(Hidden)
        function setParameters(obj)
            streamSelection='Audio only';
            setSampleTimeIsFramePeriod(obj,true);
            setSampleRate(obj,obj.SampleRate);

            fileTypeInfo=dspFileTypeInfoToMultimediaFile(obj.FileFormat);


            dataType=findMatch(obj.DataTypeSet,obj.DataType);
            obj.compSetParameters({obj.privFilename,...
            1,...
            'None (uncompressed)',...
            2,...
            obj.Compressor,...
            streamSelection,...
            1,...
            obj.FileFormat,...
            dataType,...
            'RGB',...
            fileTypeInfo.AWPlugins.Device,...
            fileTypeInfo.AWPlugins.Converter,...
            fileTypeInfo.AWPlugins.Filter,...
            75,...
10...
            });
        end
        function y=callTerminateAfterCodegen(~)





            y=true;
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            propsMap=containers.Map(obj.getDisplayPropertiesImpl(),...
            false(size(obj.getDisplayPropertiesImpl())));
            fileTypeInfo=dspFileTypeInfoToMultimediaFile(obj.FileFormat);

            propsMap('DataType')=isempty(fileTypeInfo.AudioDataTypesForSfun)||...
            (strcmp(obj.FileFormat,'WAV')&&...
            ~strcmp(obj.Compressor,'None (uncompressed)'));
            propsMap('Compressor')=isempty(fileTypeInfo.AudioCompressors);

            mapKeys=keys(propsMap);
            mapVals=values(propsMap,mapKeys);
            mapVals=[mapVals{:}];
            inactiveProps=mapKeys(mapVals);

            flag=ismember(prop,inactiveProps);
        end

        function c=cloneImpl(obj)
            c=cloneHelper(obj);
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.system.SFunSystem(obj);
        end
        function obj=loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.system.SFunSystem(obj,s,wasLocked);
            if isfield(s,'pFileFormat')
                obj.FileFormat=s.pFileFormat;
            end
        end

    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsnks4/To Multimedia File';
        end

        function props=getDisplayPropertiesImpl()
            props={'Filename'...
            ,'FileFormat'...
            ,'SampleRate'...
            ,'Compressor'...
            ,'DataType'...
            };
        end


        function props=getValueOnlyProperties()
            props={'Filename'};
        end

        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.privFilename=0;
        end
    end

end

function fileTypesStringSet=getSupportedFormatsStringSet()
    fileTypesStringSet=matlab.system.StringSet(getSupportedFormats());
end

function fileTypes=getSupportedFormats()

    fileTypes=dspFileTypesToMultimediaFile;
    supportsAudio=false(size(fileTypes));

    for cnt=1:numel(fileTypes)
        fileTypeInfo=dspFileTypeInfoToMultimediaFile(fileTypes{cnt});
        supportsAudio(cnt)=any(cellfun(@(x)contains(x,'Audio'),...
        fileTypeInfo.AllWriteableStreams));
    end
    fileTypes=fileTypes(supportsAudio);
end
