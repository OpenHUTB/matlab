classdef(StrictDefaults)audioPlayerRecorder<matlab.System


%#function maudioToAudioDevice maudioFromAudioDevice

%#codegen
    properties(Nontunable)

        Device=dsp.internal.getAudioIODriversAndDevices('defaultFullDuplexDevice');

        SampleRate=44100;
        BitDepth='16-bit integer';
        PlayerChannelMapping=[];
        RecorderChannelMapping=1;
        BufferSize=1024;        SupportVariableSize(1,1)logical=false;
    end


    properties(Constant,Hidden,Nontunable)
        BitDepthSet=matlab.system.StringSet({'8-bit integer',...
        '16-bit integer','24-bit integer','32-bit float'});
    end


    properties(Transient,Hidden,Dependent)%#ok<*MDEPIN>        DeviceSet=matlab.system.StringSet(dsp.internal.getAudioIODriversAndDevices('fullDuplexDevices'));
    end


    properties(Nontunable,Access=private)

pADW
pADR
pDataType
    end


    properties(Access=private)
        pNumChannels=-1
        pWriterFrameSize=0
pBufferWriter
pBufferReader
    end


    methods
        function obj=audioPlayerRecorder(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                matlab.internal.lang.capability.Capability.require(...
                matlab.internal.lang.capability.Capability.LocalClient);
            end
            setProperties(obj,nargin,varargin{:},'SampleRate');
        end


        function val=get.DeviceSet(~)
            val=matlab.system.StringSet(dsp.internal.getAudioIODriversAndDevices('fullDuplexDevices'));
        end


        function set.PlayerChannelMapping(obj,val)
            if isempty(val)
                validateattributes(val,{'numeric'},{},...
                'set.PlayerChannelMapping','PlayerChannelMapping');
            else
                validateattributes(val,{'numeric'},{'finite','real','vector','positive'},...
                'set.PlayerChannelMapping','PlayerChannelMapping');
            end
            obj.PlayerChannelMapping=double(val);
        end


        function set.RecorderChannelMapping(obj,val)
            validateattributes(val,{'numeric'},{'finite','real','vector','positive','nonempty'},...
            'set.RecorderChannelMapping','RecorderChannelMapping');
            obj.RecorderChannelMapping=double(val);
        end


        function set.SampleRate(obj,val)
            validateattributes(val,{'double','single'},...
            {'real','scalar','positive','finite'},...
            'set.SampleRate','SampleRate');
            obj.SampleRate=val;
        end


        function devCell=getAudioDevices(~)
            devCell=dsp.internal.getAudioIODriversAndDevices('fullDuplexDevices');
        end
    end


    methods(Access=protected)

        function setupImpl(obj,u)
            coder.extrinsic('dsp.internal.getAudioIODriversAndDevices');
            driver=coder.const(@dsp.internal.getAudioIODriversAndDevices,'fullDuplexDriver');
            if strcmp(obj.Device,'Default')
                device=coder.const(@dsp.internal.getAudioIODriversAndDevices,'defaultFullDuplexDeviceName');
            else
                device=obj.Device;
            end
            simulateSilence=(coder.target('MATLAB')&&getpref('dsp','portaudioHostApi')==-1);

            dt=class(u);
            bufferSize=size(u,1);
            if obj.SupportVariableSize
                bufferSize=obj.BufferSize;
                validateattributes(bufferSize,{'numeric'},{'scalar','>',1},'audioPlayerRecorder','BufferSize');
                obj.pBufferWriter=dsp.AsyncBuffer('Capacity',384e3);
                obj.pBufferReader=dsp.AsyncBuffer('Capacity',384e3+bufferSize);
                setup(obj.pBufferReader,zeros(bufferSize,numel(obj.RecorderChannelMapping),dt));
                setup(obj.pBufferWriter,zeros(bufferSize,size(u,2),dt));
            end

            if isempty(obj.PlayerChannelMapping)
                if simulateSilence
                    obj.pADW=audioDeviceWriter('Driver',driver{1},...
                    'SampleRate',obj.SampleRate,...
                    'BitDepth',obj.BitDepth,'ChannelMappingSource','Auto');
                else
                    obj.pADW=audioDeviceWriter('Driver',driver{1},...
                    'Device',device,'SampleRate',obj.SampleRate,...
                    'BitDepth',obj.BitDepth,'ChannelMappingSource','Auto');
                end
            else
                if simulateSilence
                    obj.pADW=audioDeviceWriter('Driver',driver{1},...
                    'SampleRate',obj.SampleRate,...
                    'BitDepth',obj.BitDepth,'ChannelMappingSource','Property',...
                    'ChannelMapping',obj.PlayerChannelMapping);
                else
                    obj.pADW=audioDeviceWriter('Driver',driver{1},...
                    'Device',device,'SampleRate',obj.SampleRate,...
                    'BitDepth',obj.BitDepth,'ChannelMappingSource','Property',...
                    'ChannelMapping',obj.PlayerChannelMapping);
                end
            end

            if simulateSilence
                obj.pADR=audioDeviceReader('Driver',driver{1},...
                'SampleRate',obj.SampleRate,...
                'BitDepth',obj.BitDepth,'OutputDataType',dt,...
                'ChannelMappingSource','Property',...
                'ChannelMapping',obj.RecorderChannelMapping,...
                'SamplesPerFrame',bufferSize);
            else
                obj.pADR=audioDeviceReader('Driver',driver{1},...
                'Device',device,'SampleRate',obj.SampleRate,...
                'BitDepth',obj.BitDepth,'OutputDataType',dt,...
                'ChannelMappingSource','Property',...
                'ChannelMapping',obj.RecorderChannelMapping,...
                'SamplesPerFrame',bufferSize);
            end

            setup(obj.pADR);
            setup(obj.pADW,zeros(bufferSize,size(u,2),dt));

            obj.pNumChannels=size(u,2);
            obj.pDataType=dt;
        end

        function[y,underruns,overruns]=stepImpl(obj,u)
            if~obj.SupportVariableSize

                underruns=play(obj.pADW,u);
                [y,overruns]=record(obj.pADR);
            else

                overruns=uint32(0);
                underruns=uint32(0);
                bufferSize=obj.BufferSize;
                br=obj.pBufferReader;
                bw=obj.pBufferWriter;
                write(bw,u);
                while bw.NumUnreadSamples>=bufferSize
                    x=read(bw,bufferSize);
                    underruns=underruns+play(obj.pADW,x);
                    [yout,overrunsAdd]=record(obj.pADR);
                    overruns=overruns+overrunsAdd;
                    write(br,yout);
                end
                y=read(br,size(u,1));
            end
        end


        function resetImpl(obj)
            reset(obj.pADW);
            reset(obj.pADR);
            if obj.SupportVariableSize
                reset(obj.pBufferWriter);
                reset(obj.pBufferReader);
                nCh=numel(obj.pADR.ChannelMapping);
                write(obj.pBufferReader,zeros(obj.BufferSize,nCh,obj.pDataType));
            end
        end


        function releaseImpl(obj)
            release(obj.pADW);
            release(obj.pADR);
            obj.pNumChannels=-1;
            if obj.SupportVariableSize
                release(obj.pBufferWriter);
                release(obj.pBufferReader);
            end
        end


        function validatePropertiesImpl(obj)
            if coder.target('MATLAB')&&getpref('dsp','portaudioHostApi')~=-1
                coder.internal.errorIf(strcmp(obj.Device,...
                getString(message('audio:audioPlayerRecorder:noDevice'))),...
                'audio:audioPlayerRecorder:noDevice');
            end
        end


        function validateInputsImpl(obj,u)

            validateattributes(u,{'single','double','int16','int32','uint8'},...
            {'2d','real','nonempty'},'input');

            if obj.SupportVariableSize
                obj.pWriterFrameSize=0;
            else
                if~isLocked(obj)||obj.pWriterFrameSize==0
                    obj.pWriterFrameSize=size(u,1);
                else
                    coder.internal.errorIf(size(u,1)~=obj.pWriterFrameSize,...
                    'dsp:audioDeviceIO:inputFrameSizeChanged','SupportVariableSize');
                end
                coder.internal.errorIf(size(u,1)==1,'audio:audioPlayerRecorder:invalidFrameSize');
            end

            if~isempty(obj.PlayerChannelMapping)
                numChannels=size(u,2);
                coder.internal.errorIf(numChannels>length(obj.PlayerChannelMapping),...
                'audio:audioPlayerRecorder:invalidChannels');
            end

            if obj.pNumChannels==-1
                return;
            end
            coder.internal.errorIf(size(u,2)~=obj.pNumChannels,...
            'dsp:system:Shared:numChannels');
        end


        function flag=isInactivePropertyImpl(obj,prop)

            flag=false;
            switch prop
            case 'BufferSize'
                flag=~obj.SupportVariableSize;
            end

        end


        function devInfo=infoImpl(obj)
            driver=dsp.internal.getAudioIODriversAndDevices('fullDuplexDriver');
            driver=driver{1};
            devInfo.Driver=driver;
            if~any(strcmp(obj.Device,...
                dsp.internal.getAudioIODriversAndDevices('fullDuplexDevices',driver)))
                devInfo.DeviceName=getString(message('audio:audioPlayerRecorder:noDevice'));
                devInfo.MaximumRecorderChannels=0;
                devInfo.MaximumPlayerChannels=0;
            else
                if strcmp(obj.Device,'Default')
                    devInfo.DeviceName=dsp.internal.getAudioIODriversAndDevices('defaultFullDuplexDeviceName');
                else
                    devInfo.DeviceName=obj.Device;
                end
                driverIdx=dsp.internal.getAudioIODriversAndDevices('driverIndex',driver);
                if strcmp(devInfo.DeviceName,'ALSAdefault')&&isunix
                    devInfo.MaximumRecorderChannels=computeMaxChannelsForDevice('default','input',driverIdx);
                    devInfo.MaximumPlayerChannels=computeMaxChannelsForDevice('default','output',driverIdx);
                else
                    devInfo.MaximumRecorderChannels=computeMaxChannelsForDevice(devInfo.DeviceName,'input',driverIdx);
                    devInfo.MaximumPlayerChannels=computeMaxChannelsForDevice(devInfo.DeviceName,'output',driverIdx);
                end
            end
        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            s.pADW=matlab.System.saveObject(obj.pADW);
            s.pADR=matlab.System.saveObject(obj.pADR);
            s.SaveLockedData=false;
        end


        function loadObjectImpl(obj,s,~)
            currDevice=s.Device;
            availableDevices=dsp.internal.getAudioIODriversAndDevices(...
            'fullDuplexDevices');
            if~any(strcmp(currDevice,availableDevices))
                coder.internal.warning('audio:audioPlayerRecorder:invalidDevice',...
                currDevice);
                s.Device=availableDevices{1};
            end
            loadObjectImpl@matlab.System(obj,s);
            obj.pADW=matlab.System.loadObject(s.pADW);
            obj.pADR=matlab.System.loadObject(s.pADR);
        end


        function flag=isInputSizeMutableImpl(~,~)
            flag=true;
        end
    end


    methods(Static,Access=protected)
        function groups=getPropertyGroupsImpl
            mainProps={'Device','SampleRate'};
            advancedProps={'BitDepth','SupportVariableSize','BufferSize',...
            'PlayerChannelMapping','RecorderChannelMapping'};
            advancedGroupTitle=getString(message('dsp:system:Shared:AdvancedProperties'));
            mainGroup=matlab.system.display.SectionGroup('TitleSource',...
            'Auto','PropertyList',mainProps);
            advancedGroup=matlab.system.display.SectionGroup('Title',...
            advancedGroupTitle,'PropertyList',advancedProps);
            groups=[mainGroup,advancedGroup];
        end
    end


    methods(Hidden,Static)
        function flag=isAllowedInSystemBlock(~)
            flag=false;
        end
    end

end
