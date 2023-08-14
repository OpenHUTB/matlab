classdef AudioPlayback<ioplayback.SinkSystem&coder.ExternalDependency






%#codegen
%#ok<*EMCA>
    properties(Nontunable)

        DeviceName='plughw:0,0'

        SampleRate=44100

        QueueDuration=0.5
        DataTypeWarningasError=0;
    end

    properties(Hidden,Nontunable)

        DataType='int16'
    end

    methods
        function obj=AudioPlayback(varargin)
            coder.allowpcode('plain');
            obj.DeviceType='Audio Playback';
            setProperties(obj,nargin,varargin{:});
        end

        function open(obj,samplesPerFrame,numberOfChannels)









            coder.cinclude('MW_AudioIO.h');
            coder.ceval('MW_AudioOpen',...
            ioplayback.util.cstring(obj.DeviceName),...
            obj.SampleRate,...
            numberOfChannels,...
            obj.QueueDuration,...
            samplesPerFrame,...
            1);
        end

        function writeStream(obj,u)

            coder.ceval('MW_AudioWrite',ioplayback.util.cstring(obj.DeviceName),coder.rref(u));
        end

        function close(obj)


            coder.ceval('MW_AudioClose',ioplayback.util.cstring(obj.DeviceName),1);
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)
            samplesPerFrame=size(varargin{1},1);
            numberOfChannels=size(varargin{1},2);
            if isempty(coder.target)

                obj.DataFileFormat='Wave';
                obj.SignalInfo.Name='AudioPlayback';
                obj.SignalInfo.Dimensions=[samplesPerFrame,numberOfChannels];
                obj.SignalInfo.DataType=class(varargin{1});
                obj.SignalInfo.IsComplex=false;
                setupImpl@ioplayback.SinkSystem(obj,varargin{1});
            else
                open(obj,samplesPerFrame,numberOfChannels);
            end
        end

        function varargout=stepImpl(obj,varargin)

            if isempty(coder.target)

                if isequal(obj.SendSimulationInputTo,'Output port')
                    varargout{1}=varargin{1};
                elseif isequal(obj.SendSimulationInputTo,'Data file')
                    stepImpl@ioplayback.SinkSystem(obj,varargin{1});
                end
            else

                writeStream(obj,varargin{1});
                if isequal(obj.SendSimulationInputTo,'Output port')
                    varargout{1}=varargin{1};
                end
            end
        end

        function releaseImpl(obj)
            if isempty(coder.target)
                releaseImpl@ioplayback.SinkSystem(obj);
            else
                close(obj);
            end
        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=1;
        end

        function num=getNumOutputsImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                num=1;
            else
                num=0;
            end
        end

        function icon=getIconImpl(obj)

            icon=sprintf('D=%s\nS=%d',obj.DeviceName,obj.SampleRate);
        end

        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end

        function validateInputsImpl(~,varargin)
            if~isempty(coder.target)

                validateattributes(varargin{1},{'int16'},{'2d'},'',...
                'signal input');
            end
        end
    end

    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl(~)
            simMode='Interpreted execution';
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

        function header=getHeaderImpl()
            header=matlab.system.display.Header(mfilename('class'),...
            'ShowSourceLink',false,...
            'Title','Audio Playback',...
            'Text',[['Write audio to a sound card.',char(10),char(10)]...
            ,'Do not use the same audio device multiple times.']);%#ok<CHARTEN>
        end

        function groups=getPropertyGroupsImpl()
            mainGroup=matlab.system.display.SectionGroup('Title','Main',...
            'PropertyList',{'DeviceName','SampleRate','QueueDuration'});
            simulationGroup=matlab.system.display.SectionGroup('Title','Simulation',...
            'PropertyList',{'SendSimulationInputTo','DatasetName','SourceName'});
            groups=[mainGroup,simulationGroup];
        end
    end

    methods(Static)
        function name=getDescriptiveName()
            name='Audio Playback';
        end

        function b=isSupportedContext(context)
            b=context.isCodeGenTarget('rtw');
        end

        function updateBuildInfo(buildInfo,context)
            if context.isCodeGenTarget('rtw')

                svdRootDir=matlabshared.svd.internal.getRootDir;
                tmp=fileparts(fileparts(fileparts(mfilename('fullpath'))));
                srcDir=fullfile(tmp,'src');
                includeDir=fullfile(tmp,'include');
                addIncludePaths(buildInfo,includeDir);
                addIncludePaths(buildInfo,fullfile(svdRootDir,'include'));


                addIncludeFiles(buildInfo,'MW_AudioIO.h',includeDir);
                addSourceFiles(buildInfo,'MW_AudioIO_ALSA.c',srcDir);
                addLinkFlags(buildInfo,{'-lasound'},'SkipForSil');
            end
        end
    end
end

