classdef audioDeviceReader<matlab.system.SFunSystem&...
    matlab.system.mixin.FiniteSource



    properties(Nontunable)
        SampleRate=44100;
        NumChannels=1;
        BitDepth='16-bit integer';
        SamplesPerFrame=1024;
        OutputDataType='double';
        ChannelMapping=[];
        NumBuffers=10;
        Driver=dsp.internal.getAudioIODriversAndDevices('defaultDriver');
    end



    properties(Nontunable,SetObservable)
        Device=dsp.internal.getAudioIODriversAndDevices('defaultInputDevice');
        ChannelMappingSource='Auto';
    end

    properties(Constant,Hidden,Nontunable)
        BitDepthSet=matlab.system.StringSet({...
        '8-bit integer',...
        '16-bit integer',...
        '24-bit integer',...
        '32-bit float'});

        OutputDataTypeSet=matlab.system.StringSet({...
        'uint8','int16','int32','single','double'});

        ChannelMappingSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property'});
    end

    properties(Transient,Hidden)
        DeviceSet=matlab.system.StringSet(dsp.internal.getAudioIODriversAndDevices('inputDevices',...
        dsp.internal.getAudioIODriversAndDevices('defaultDriver')));
        DriverSet=matlab.system.StringSet(dsp.internal.getAudioIODriversAndDevices('drivers'));
    end

    methods

        function obj=audioDeviceReader(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('maudioFromAudioDevice')

            publicProps=audiointerface.audioDeviceReader.getDisplayPropertiesImpl();

            if nargin>1
                [varargin{:}]=convertStringsToChars(varargin{:});
            end

            if mod(length(varargin),2)~=0&&isnumeric(varargin{1})

                varargin=['SampleRate',varargin];
            elseif mod(length(varargin),2)==0&&...
                length(varargin)>=2&&...
                ~any(strcmp(char(varargin{1}),publicProps))


                varargin={'SampleRate',varargin{1},...
                'SamplesPerFrame',varargin{2:end}};
            end


            args=cell(0);
            if mod(length(varargin),2)~=0||...
                ~iscellstr(varargin(1:2:end))
                error(message('audio:audioDeviceReader:invalidArgs'));
            else
                temp=regexp(varargin(1:2:end),'Device');
            end

            hasDevSpecified=~isempty(cell2mat(temp));
            for idx=1:2:length(varargin)
                if~isempty(temp{(idx+1)/2})
                    devNameSpecified=varargin{idx+1};
                else
                    args=[args,varargin(idx:idx+1)];%#ok
                end
            end

            addlistener(obj,'ChannelMappingSource',...
            'PostSet',@audiointerface.audioDeviceReader.updateDefaultChannelMapping);

            addlistener(obj,'Device',...
            'PostSet',@audiointerface.audioDeviceReader.updateDefaultChannelMapping);

            setProperties(obj,length(args),args{:},'SampleRate',...
            'SamplesPerFrame');

            if~isempty(getIndex(obj.DeviceSet,...
                getString(message('dsp:audioDeviceIO:noInputDevice'))))
                obj.Device=getString(message('dsp:audioDeviceIO:noInputDevice'));
                if hasDevSpecified&&...
                    ~strcmpi(devNameSpecified,getString(message('dsp:audioDeviceIO:noInputDevice')))
                    warning(message('audio:audioDeviceReader:noAudioDevice',...
                    devNameSpecified));
                end
            elseif hasDevSpecified
                obj.Device=devNameSpecified;
            end

            if isempty(obj.ChannelMapping)
                obj.computeDefaultChannelMapping();
            end
        end

        function val=get.DeviceSet(obj)
            val=matlab.system.StringSet(...
            dsp.internal.getAudioIODriversAndDevices('inputDevices',obj.Driver));
        end

        function devCell=getAudioDevices(obj)
            devCell=dsp.internal.getAudioIODriversAndDevices('inputDevices',obj.Driver);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            BitDepthIdx=getIndex(obj.BitDepthSet,obj.BitDepth)+1;

            OutputDataTypeIdx=getIndex(...
            obj.OutputDataTypeSet,lower(obj.OutputDataType));

            useDefaultInputChannelMapping=2-getIndex(...
            obj.ChannelMappingSourceSet,obj.ChannelMappingSource);

            localDevice=obj.Device;
            if strcmpi(localDevice,'ALSAdefault')
                localDevice='default';
            end

            if getpref('dsp','portaudioHostApi')~=-1
                driverIdx=dsp.internal.getAudioIODriversAndDevices('driverIndex',obj.Driver);
            else

                driverIdx=-1;
            end

            obj.compSetParameters({localDevice,...
            obj.NumChannels,...
            obj.SampleRate,...
            BitDepthIdx,...
            obj.NumBuffers,...
            obj.SamplesPerFrame,...
            OutputDataTypeIdx,...
            useDefaultInputChannelMapping,...
            obj.ChannelMapping,...
            1,...
            driverIdx,...
            1,...
            });
        end
    end

    methods(Access=protected)

        function c=cloneImpl(obj)
            c=cloneHelper(obj);
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.system.SFunSystem(obj);

            s.SaveLockedData=false;
        end
    end

    methods(Static,Hidden)

        function a=getAlternateBlock
            a='audiosources/Audio Device Input';
        end

        function props=getDisplayPropertiesImpl()
            props={'SampleRate',...
            'NumChannels',...
            'BitDepth',...
            'SamplesPerFrame',...
            'OutputDataType',...
            'ChannelMapping',...
            'NumBuffers',...
            'Driver',...
            'Device',...
'ChannelMappingSource'...
            };
        end



        function props=getValueOnlyProperties()
            props={'SampleRate','SamplesPerFrame'};
        end

        function updateDefaultChannelMapping(~,eventData)
            obj=eventData.AffectedObject;
            if strcmp(obj.ChannelMappingSource,'Auto')&&getpref('dsp','portaudioHostApi')~=-1
                obj.computeDefaultChannelMapping();
            end
        end
    end

    methods(Sealed,Hidden)
        function close(obj)




            warning(message('MATLAB:system:throwObsoleteMethodWarningNewName',...
            class(obj),'close','release'));
            release(obj);
        end
    end

    methods(Hidden,Access=private)
        function computeDefaultChannelMapping(obj)
            driverIdx=dsp.internal.getAudioIODriversAndDevices('driverIndex',obj.Driver);
            maxChannels=computeMaxChannelsForDevice(obj.Device,'input',driverIdx);
            if maxChannels==0
                obj.ChannelMapping=0;
            else
                obj.ChannelMapping=1:maxChannels;
            end
        end
    end
end
