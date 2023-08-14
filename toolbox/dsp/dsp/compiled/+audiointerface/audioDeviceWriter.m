classdef audioDeviceWriter<matlab.system.SFunSystem




%#ok<*EMCLS>
%#ok<*EMCA>
    properties(Nontunable)
        SampleRate=44100;
        BufferSize=4096;
        BitDepth='16-bit integer';
        ChannelMapping=[];
        NumBuffers=10;
        Driver=dsp.internal.getAudioIODriversAndDevices('defaultDriver');
        SupportVariableSizeInput(1,1)logical=false;
    end

    properties(Hidden,Transient)
        DriverSet=matlab.system.StringSet(dsp.internal.getAudioIODriversAndDevices('drivers'));
    end



    properties(Nontunable,SetObservable)
        Device=dsp.internal.getAudioIODriversAndDevices('defaultOutputDevice');
        ChannelMappingSource='Auto';
    end

    properties(Constant,Hidden)
        BitDepthSet=matlab.system.StringSet({...
        '8-bit integer',...
        '16-bit integer',...
        '24-bit integer',...
        '32-bit float'});
        ChannelMappingSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property'});
    end

    properties(Transient,Hidden)
        DeviceSet=matlab.system.StringSet(dsp.internal.getAudioIODriversAndDevices('outputDevices',...
        dsp.internal.getAudioIODriversAndDevices('defaultDriver')));
    end

    methods

        function obj=audioDeviceWriter(varargin)
            coder.allowpcode('plain');

            if nargin>1
                [varargin{:}]=convertStringsToChars(varargin{:});
            end

            if mod(length(varargin),2)~=0&&isnumeric(varargin{1})

                varargin=['SampleRate',varargin];
            end


            args=cell(0);
            coder.internal.errorIf(mod(length(varargin),2)~=0||...
            ~iscellstr(varargin(1:2:end)),...
            'dsp:system:audioDeviceWriter:invalidArgs');

            temp=regexp(varargin(1:2:end),'Device');

            hasDevSpecified=~isempty(cell2mat(temp));
            for idx=1:2:length(varargin)
                if~isempty(temp{(idx+1)/2})
                    devNameSpecified=varargin{idx+1};
                else
                    args=[args,varargin(idx:idx+1)];%#ok
                end
            end

            obj@matlab.system.SFunSystem('maudioToAudioDevice');

            addlistener(obj,'ChannelMappingSource',...
            'PostSet',@audiointerface.audioDeviceWriter.updateDefaultChannelMapping);

            addlistener(obj,'Device',...
            'PostSet',@audiointerface.audioDeviceWriter.updateDefaultChannelMapping);

            setProperties(obj,length(args),args{:});

            if~isempty(getIndex(obj.DeviceSet,...
                getString(message('dsp:audioDeviceIO:noOutputDevice'))))
                obj.Device=getString(message('dsp:audioDeviceIO:noOutputDevice'));
                if hasDevSpecified&&...
                    ~strcmpi(devNameSpecified,getString(message('dsp:audioDeviceIO:noOutputDevice')))
                    coder.internal.warning('dsp:system:audioDeviceWriter:noAudioDevice',...
                    devNameSpecified);
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
            dsp.internal.getAudioIODriversAndDevices('outputDevices',obj.Driver));
        end

        function devCell=getAudioDevices(obj)
            devCell=dsp.internal.getAudioIODriversAndDevices('outputDevices',obj.Driver);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            BitDepthIdx=getIndex(obj.BitDepthSet,obj.BitDepth)+1;

            useDefaultOutputChannelMapping=2-getIndex(...
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
            0,...
            obj.SampleRate,...
            BitDepthIdx,...
            obj.BufferSize,...
            obj.NumBuffers,...
            useDefaultOutputChannelMapping,...
            obj.ChannelMapping,...
            1,...
            driverIdx,...
            double(obj.SupportVariableSizeInput)...
            });
        end

        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;

            switch(prop)
            case 'ChannelMapping'
                if~strcmp(obj.ChannelMappingSource,'Property')
                    flag=true;
                end
            end
        end

        function loadObjectImpl(obj,s,~)
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.system.SFunSystem(obj);

            s.SaveLockedData=false;
        end

        function c=cloneImpl(obj)
            c=cloneHelper(obj);
        end
    end

    methods(Static,Hidden)

        function props=getDisplayPropertiesImpl()
            props={'SampleRate',...
            'BufferSize',...
            'BitDepth',...
            'ChannelMapping',...
            'NumBuffers',...
            'Driver',...
            'Device',...
            'SupportVariableSizeInput',...
'ChannelMappingSource'...
            };
        end



        function props=getValueOnlyProperties()
            props={'SampleRate'};
        end

        function updateDefaultChannelMapping(~,eventData)
            obj=eventData.AffectedObject;
            if strcmp(obj.ChannelMappingSource,'Auto')&&getpref('dsp','portaudioHostApi')~=-1
                obj.computeDefaultChannelMapping();
            end
        end

    end

    methods(Hidden,Access=private)
        function computeDefaultChannelMapping(obj)
            driverIdx=dsp.internal.getAudioIODriversAndDevices('driverIndex',obj.Driver);
            maxChannels=computeMaxChannelsForDevice(obj.Device,'output',driverIdx);
            if maxChannels==0
                obj.ChannelMapping=0;
            else
                obj.ChannelMapping=1:maxChannels;
            end
        end
    end
end