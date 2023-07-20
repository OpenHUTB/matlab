classdef AudioCapture<ioplayback.SourceSystem&coder.ExternalDependency&...
    ioplayback.system.mixin.Event






%#codegen
%#ok<*EMCA>
    properties(Nontunable)

        DeviceName='plughw:0,0'

        SampleRate=44100

        SamplesPerFrame=4410

        NumberOfChannels=2

        QueueDuration=0.5

    end

    properties(Hidden,Nontunable)

        DataType='int16'
    end

    properties(Constant,Access=private)
        EVENTID='ADCINT'
    end

    properties(Access=private)
        EventTick=0
    end

    methods
        function obj=AudioCapture(varargin)
            coder.allowpcode('plain');
            obj.DeviceType='Audio Capture';
            setProperties(obj,nargin,varargin{:});
            obj.DataTypeWarningasError=0;
        end

        function open(obj,samplesPerFrame,numberOfChannels)









            coder.cinclude('MW_AudioIO.h');
            coder.ceval('MW_AudioOpen',...
            ioplayback.util.cstring(obj.DeviceName),...
            obj.SampleRate,...
            numberOfChannels,...
            obj.QueueDuration,...
            samplesPerFrame,...
            0);
        end

        function y=readStream(obj)

            y=coder.nullcopy(zeros([obj.SamplesPerFrame,obj.NumberOfChannels],obj.DataType));
            coder.ceval('MW_AudioRead',ioplayback.util.cstring(obj.DeviceName),coder.wref(y));
        end

        function close(obj)


            coder.ceval('MW_AudioClose',ioplayback.util.cstring(obj.DeviceName),0);
        end

        function st=getFrameTime(obj)
            st=obj.SamplesPerFrame/obj.SampleRate;
        end

        function event=getNextEvent(obj,eventID,~)
            if isequal(obj.SimulationOutput,'From input port')||isequal(obj.SimulationOutput,'Zeros')
                event=[];
                return;
            end

            event.ID=eventID;
            sampleTime=obj.SamplesPerFrame/obj.SampleRate;
            event.Time=sampleTime*obj.EventTick;
            obj.EventTick=obj.EventTick+1;
        end

        function checkDataFile(obj,dataFile)%#ok<INUSD>
            if isempty(coder.target)





            end
        end

    end

    methods(Access=protected)
        function setupImpl(obj,varargin)
            obj.EventTick=0;
            if isempty(coder.target)

                if isequal(obj.SimulationOutput,'From input port')
                    validateattributes(varargin{1},{obj.DataType},...
                    {'size',[obj.SamplesPerFrame,obj.NumberOfChannels]},'AudioCapture','input');
                else
                    obj.DataFileFormat='Wave';
                    obj.SignalInfo.Name='AudioCapture';
                    obj.SignalInfo.Dimensions=[obj.SamplesPerFrame,obj.NumberOfChannels];
                    obj.SignalInfo.DataType=obj.DataType;
                    obj.SignalInfo.IsComplex=false;
                    setupImpl@ioplayback.SourceSystem(obj);
                    if isequal(obj.SimulationOutput,'From recorded file')
                        setup(obj.Reader);
                    end
                end

                if isequal(obj.SimulationOutput,'From recorded file')
                    try %#ok<EMTC>
                        events=struct('EventID',obj.EVENTID,...
                        'CommType','pull','TaskFcnPollCmd','');
                        soc.registerBlock(obj,events);
                    catch ME
                        disp(ME.message)
                    end
                end
            else
                samplesPerFrame=obj.SamplesPerFrame;
                numberOfChannels=obj.NumberOfChannels;
                open(obj,samplesPerFrame,numberOfChannels);
            end
        end

        function varargout=stepImpl(obj,varargin)
            if isempty(coder.target)

                if isequal(obj.SimulationOutput,'From input port')
                    varargout{1}=varargin{1};
                elseif isequal(obj.SimulationOutput,'From recorded file')
                    varargout{1}=stepImpl@ioplayback.SourceSystem(obj);
                else

                    varargout{1}=zeros([obj.SamplesPerFrame,obj.NumberOfChannels],obj.DataType);
                end
            else

                varargout{1}=readStream(obj);
            end
        end

        function releaseImpl(obj)
            if isempty(coder.target)
                if~isequal(obj.SimulationOutput,'From input port')
                    releaseImpl@ioplayback.SourceSystem(obj);
                end
            else
                close(obj);
            end
        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            if isequal(obj.SimulationOutput,'From input port')
                num=1;
            else
                num=0;
            end
        end

        function num=getNumOutputsImpl(~)
            num=1;
        end

        function varargout=isOutputFixedSizeImpl(~,~)
            varargout{1}=true;
        end

        function varargout=isOutputComplexImpl(~)
            varargout{1}=false;
        end

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=[obj.SamplesPerFrame,obj.NumberOfChannels];
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=obj.DataType;
        end

        function sts=getSampleTimeImpl(obj,varargin)

            sys=fileparts(gcb);
            if~isequal(sys,bdroot(gcb))&&isequal(get_param(sys,'BlockType'),'SubSystem')&&...
                isequal(get_param(sys,'SystemSampleTime'),'-1')
                sts=createSampleTime(obj,'Type','Inherited');
            else
                st=obj.SamplesPerFrame/obj.SampleRate;
                sts=createSampleTime(obj,'Type','Discrete','SampleTime',st);
            end
        end

        function icon=getIconImpl(obj)

            icon=sprintf('D=%s\nS=%d',obj.DeviceName,...
            obj.SampleRate);
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
            'Title','Audio Capture',...
            'Text',[['Read audio from a sound carde.',char(10),char(10)]...
            ,'Do not use the same audio device multiple times.']);%#ok<CHARTEN>
        end

        function groups=getPropertyGroupsImpl()
            mainGroup=matlab.system.display.SectionGroup('Title','Main',...
            'PropertyList',{'DeviceName','SampleRate',...
            'SamplesPerFrame','NumberOfChannels','QueueDuration'});
            simulationGroup=matlab.system.display.SectionGroup('Title','Simulation',...
            'PropertyList',{'SimulationOutput','DatasetName','SourceName'});

            groups=[mainGroup,simulationGroup];
        end
    end

    methods(Static)
        function name=getDescriptiveName()
            name='Audio Capture';
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

