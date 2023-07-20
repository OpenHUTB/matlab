classdef(StrictDefaults)audioDeviceWriter<matlab.System

























































































%#function maudioToAudioDevice

%#codegen
    properties(Nontunable,Dependent)



SampleRate




BufferSize




BitDepth






ChannelMapping












Driver
    end

    properties(Nontunable)









        SupportVariableSizeInput(1,1)logical
    end

    properties(Hidden,Nontunable,Dependent)




NumBuffers
    end



    properties(Nontunable,SetObservable,Dependent)


Device



ChannelMappingSource
    end

    properties(Constant,Hidden,Nontunable)
        BitDepthSet=matlab.system.StringSet({...
        '8-bit integer',...
        '16-bit integer',...
        '24-bit integer',...
        '32-bit float'});

        ChannelMappingSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property'});
    end

    properties(Transient,Hidden,Dependent)
        DeviceSet=matlab.system.StringSet(...
        dsp.internal.getAudioIODriversAndDevices(...
        'outputDevices',...
        dsp.internal.getAudioIODriversAndDevices('defaultDriver')));%#ok<MDEPIN>

        DriverSet=matlab.system.StringSet(...
        dsp.internal.getAudioIODriversAndDevices('drivers'));%#ok
    end

    properties(Access=private,Nontunable)
        pInterface;
    end

    properties(Access=private)
        pInputFrameSize=0;
    end

    methods
        function obj=audioDeviceWriter(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')

                matlab.internal.lang.capability.Capability.require(...
                matlab.internal.lang.capability.Capability.LocalClient);
            end

            obj.pInterface=audiointerface.audioDeviceWriter(varargin{:});
        end

        function underrun=play(obj,u)





            underrun=step(obj,u);
        end

        function devCell=getAudioDevices(obj)





            devCell=getAudioDevices(obj.pInterface);
        end


        function val=get.SampleRate(obj)
            val=obj.pInterface.SampleRate;
        end

        function set.SampleRate(obj,val)
            obj.pInterface.SampleRate=val;
        end


        function val=get.BufferSize(obj)
            val=obj.pInterface.BufferSize;
        end

        function set.BufferSize(obj,val)
            obj.pInterface.BufferSize=val;
        end


        function val=get.DeviceSet(obj)
            val=obj.pInterface.DeviceSet;
        end

        function val=get.Device(obj)
            val=obj.pInterface.Device;
        end

        function set.Device(obj,val)
            obj.pInterface.Device=val;
        end


        function val=get.DriverSet(obj)
            val=obj.pInterface.DriverSet;
        end

        function val=get.Driver(obj)
            val=obj.pInterface.Driver;
        end

        function set.Driver(obj,val)
            obj.pInterface.Driver=val;
        end


        function val=get.BitDepth(obj)
            val=obj.pInterface.BitDepth;
        end

        function set.BitDepth(obj,val)
            obj.pInterface.BitDepth=val;
        end


        function val=get.ChannelMapping(obj)
            val=obj.pInterface.ChannelMapping;
        end

        function set.ChannelMapping(obj,val)
            obj.pInterface.ChannelMapping=val;
        end


        function val=get.NumBuffers(obj)
            val=obj.pInterface.NumBuffers;
        end

        function set.NumBuffers(obj,val)
            obj.pInterface.NumBuffers=val;
        end


        function val=get.SupportVariableSizeInput(obj)
            val=obj.pInterface.SupportVariableSizeInput;
        end

        function set.SupportVariableSizeInput(obj,val)
            obj.pInterface.SupportVariableSizeInput=val;%#ok
        end


        function val=get.ChannelMappingSource(obj)
            val=obj.pInterface.ChannelMappingSource;
        end

        function set.ChannelMappingSource(obj,val)
            obj.pInterface.ChannelMappingSource=val;
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'ChannelMapping'
                flag=~strcmp(obj.ChannelMappingSource,'Property');
            case 'BufferSize'
                flag=~obj.SupportVariableSizeInput;
            case 'Driver'
                flag=~ispc;
            end
        end

        function validateInputsImpl(obj,u)
            if~obj.SupportVariableSizeInput
                if(obj.pInputFrameSize~=0)


                    coder.internal.errorIf(size(u,1)~=obj.pInputFrameSize,...
                    'dsp:audioDeviceIO:inputFrameSizeChanged','SupportVariableSizeInput');
                else


                    coder.internal.errorIf(size(u,1)>2*obj.SampleRate,...
                    'dsp:system:bufferSizeInputWrongVal');
                end
            end
        end

        function validatePropertiesImpl(obj)
            if coder.target('MATLAB')
                if getpref('dsp','portaudioHostApi')~=-1

                    coder.internal.errorIf(strcmp(obj.Device,...
                    getString(message('dsp:audioDeviceIO:noOutputDevice'))),...
                    'dsp:audioDeviceIO:noOutputDevice');
                    coder.internal.errorIf(~any(strcmp(obj.Device,...
                    dsp.internal.getAudioIODriversAndDevices('outputDevices',...
                    obj.Driver))),'dsp:audioDeviceIO:invalidDevice',...
                    obj.Device,obj.Driver,class(obj));
                end
            end
        end

        function flag=isInputSizeMutableImpl(~,~)
            flag=true;
        end

        function setupImpl(obj,u)
            setup(obj.pInterface,u);
            obj.pInputFrameSize=size(u,1);
        end

        function underrun=stepImpl(obj,u)
            underrun=step(obj.pInterface,u);
        end

        function resetImpl(obj)
            reset(obj.pInterface);
        end

        function releaseImpl(obj)
            release(obj.pInterface);
            obj.pInputFrameSize=0;
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            s.pInterface=matlab.System.saveObject(obj.pInterface);
            s.SaveLockedData=false;
        end

        function loadObjectImpl(obj,s,~)
            currDriver=s.pInterface.ChildClassData.Driver;
            availableDrivers=dsp.internal.getAudioIODriversAndDevices('drivers');
            if~any(strcmp(currDriver,availableDrivers))
                s.pInterface.ChildClassData.Driver=availableDrivers{1};
            end
            currDevice=s.pInterface.ChildClassData.Device;
            availableDevices=dsp.internal.getAudioIODriversAndDevices(...
            'outputDevices',s.pInterface.ChildClassData.Driver);
            if~any(strcmp(currDevice,availableDevices))
                coder.internal.warning('dsp:audioDeviceIO:invalidDeviceValidDriver',...
                currDevice,s.pInterface.ChildClassData.Driver);
                s.pInterface.ChildClassData.Device=availableDevices{1};
            end
            loadObjectImpl@matlab.System(obj,s);
            obj.pInterface=matlab.System.loadObject(s.pInterface);
            if strcmpi(s.pInterface.ChildClassData.ChannelMappingSource,'Property')
                obj.pInterface.ChannelMapping=s.pInterface.ChildClassData.ChannelMapping;
            end

        end

        function devInfo=infoImpl(obj)











            coder.internal.errorIf(~any(strcmp(obj.Device,...
            dsp.internal.getAudioIODriversAndDevices('outputDevices',...
            obj.Driver))),'dsp:audioDeviceIO:invalidDevice',...
            obj.Device,obj.Driver,class(obj));

            devInfo.Driver=obj.Driver;
            driverIdx=dsp.internal.getAudioIODriversAndDevices('driverIndex',obj.Driver);
            if strcmp(obj.Device,'Default')
                devInfoAll=dspAudioDeviceInfo('defaultOutput',driverIdx);
                devInfo.DeviceName=regexprep(devInfoAll.name,' \([^\(]*\)$','');
                if strcmpi(devInfo.DeviceName,'Default')&&isunix
                    devInfo.DeviceName='ALSAdefault';
                end
            else
                devInfo.DeviceName=obj.Device;
            end
            devInfo.MaximumOutputChannels=computeMaxChannelsForDevice(obj.Device,'output',driverIdx);
        end
    end

    methods(Hidden)
        function y=callTerminateAfterCodegen(~)





            y=true;
        end
    end

    methods(Static,Access=protected)
        function groups=getPropertyGroupsImpl


            mainProps={'Driver','Device','SampleRate'};
            advancedProps={'BitDepth','SupportVariableSizeInput','BufferSize',...
            'ChannelMappingSource','ChannelMapping'};
            advancedGroupTitle=getString(message('dsp:system:Shared:AdvancedProperties'));

            mainGroup=matlab.system.display.SectionGroup('TitleSource',...
            'Auto','PropertyList',mainProps);
            advancedGroup=matlab.system.display.SectionGroup('Title',...
            advancedGroupTitle,'PropertyList',advancedProps);

            groups=[mainGroup,advancedGroup];
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a=sprintf('dspsnks4/Audio Device\nWriter');
        end
    end
end
