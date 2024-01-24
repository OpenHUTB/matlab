classdef ScopesHandler<handle

    properties
        EnableTimeScope(1,1)logical=false;
        EnableSpectrumAnalyzer(1,1)logical=false;
        SampleRate(1,1){mustBeFinite,mustBePositive}=44100;
    end


    properties(SetAccess=protected)

TimeScope
SpectrumAnalyzer

        IsLocked(1,1)logical=false;

        InputChannelSelection(1,:){mustBeNonnegative}=1
        OutputChannelSelection(1,:){mustBeNonnegative}=1
    end


    properties(Access=protected)

TimeScopeVisibleListener
SpectrumAnalyzerVisibleListener

SettingsHandler
        TimeScopeDefaults=struct();
        SpectrumAnalyzerDefaults=struct();
    end


    events(NotifyAccess=protected)
TimeScopeVisibleChanged
SpectrumAnalyzerVisibleChanged
    end


    properties(Constant,Hidden)
        MaxNumChannels=2;
    end


    properties(SetAccess=immutable)
        UseScopesContainer(1,1)logical=false
    end


    methods
        function this=ScopesHandler
            this.SettingsHandler=audio.app.internal.util.AppSettingsHandler('Audio','AudioTestBench');
            this.UseScopesContainer=audio.internal.feature('UseScopesContainerInAudioTestBench');
        end


        function delete(this)

            cacheAllSettings(this);
            delete(this.TimeScopeVisibleListener);
            delete(this.SpectrumAnalyzerVisibleListener);

            delete(this.TimeScope);
            delete(this.SpectrumAnalyzer);
        end


        function set.EnableTimeScope(this,val)
            this.EnableTimeScope=val;
            if val
                createTimeScope(this);
            end
            showTimeScope(this,val);
        end


        function set.EnableSpectrumAnalyzer(this,val)
            this.EnableSpectrumAnalyzer=val;
            if val
                createSpectrumAnalyzer(this);
            end
            showSpectrumAnalyzer(this,val);
        end


        function setup(this)

            if this.EnableTimeScope
                createTimeScope(this)
            end
            if this.EnableSpectrumAnalyzer
                createSpectrumAnalyzer(this);
            end
            this.IsLocked=true;
        end


        function release(this)

            sa=this.SpectrumAnalyzer;
            if~isempty(sa)&&isobject(sa)&&isvalid(sa)
                release(sa);
            end
            ts=this.TimeScope;
            if~isempty(ts)&&isobject(ts)&&isvalid(ts)
                release(ts);
            end

            this.IsLocked=false;
        end


        function validateScopes(this,sampleInput,sampleOutput)
            initializeScopes(this,sampleInput,sampleOutput);
        end


        function process(this,inData,outData)

            if this.EnableTimeScope||this.EnableSpectrumAnalyzer
                [inDataPlot,outDataPlot]=selectDataChannels(this,inData,outData);
                if this.EnableTimeScope
                    step(this.TimeScope,[inDataPlot,outDataPlot]);
                end
                if this.EnableSpectrumAnalyzer
                    step(this.SpectrumAnalyzer,[inDataPlot,outDataPlot]);
                end
            end
        end
    end


    methods(Access=protected)
        function createTimeScope(this)
            Fs=this.SampleRate;
            ts=this.TimeScope;
            if isempty(ts)||~isvalid(ts)
                ts=this.getDefaultScope('TimeScope');
                addToScopesContainer(this,ts);
                this.TimeScope=ts;
                this.TimeScopeDefaults=get(ts);

                try
                    userSettings=getCachedSettings(this.SettingsHandler,'TimeScope');
                    orderedNames=intersect(fieldnames(get(ts)),...
                    fieldnames(userSettings),'stable');
                    userSettings=orderfields(userSettings,orderedNames);
                    ts.WarnOnInactivePropertySet=false;
                    c=onCleanup(@()set(ts,'WarnOnInactivePropertySet',true));

                    set(ts,userSettings);
                catch
                end

                ts.SampleRate=Fs;
                ts.BufferLength=Fs*4;
                this.TimeScopeVisibleListener=addlistener(getScopeSpecification(ts),...
                'Visible','PostSet',@this.onTimeScopeVisibleChanged);
            elseif isLocked(ts)

                reset(ts);
            else
                reset(ts);
                ts.SampleRate=Fs;
                ts.BufferLength=Fs*4;
            end

            updateChannelNames(this);
        end


        function createSpectrumAnalyzer(this)
            sa=this.SpectrumAnalyzer;
            if isempty(sa)||~isvalid(sa)

                sa=this.getDefaultScope('SpectrumAnalyzer');
                addToScopesContainer(this,sa);
                this.SpectrumAnalyzer=sa;
                this.SpectrumAnalyzerDefaults=get(sa);

                try
                    userSettings=getCachedSettings(this.SettingsHandler,'SpectrumAnalyzer');
                    orderedNames=intersect(fieldnames(get(sa)),...
                    fieldnames(userSettings),'stable');
                    userSettings=orderfields(userSettings,orderedNames);
                    sa.WarnOnInactivePropertySet=false;
                    c=onCleanup(@()set(sa,'WarnOnInactivePropertySet',true));

                    set(sa,userSettings);
                catch
                end
                sa.SampleRate=this.SampleRate;
                this.SpectrumAnalyzerVisibleListener=addlistener(getScopeSpecification(sa),...
                'Visible','PostSet',@this.onSpectrumAnalyzerVisibleChanged);
            elseif isLocked(sa)

                reset(sa);
            else

                reset(sa);
                sa.SampleRate=this.SampleRate;
            end

            updateChannelNames(this);
        end


        function showTimeScope(this,flag)

            ts=this.TimeScope;
            if flag
                show(ts);
                drawnow;
            elseif~isempty(ts)&&isvalid(ts)
                hide(ts);
            end
        end


        function showSpectrumAnalyzer(this,flag)

            sa=this.SpectrumAnalyzer;
            if flag
                show(sa);
                drawnow;
            elseif~isempty(sa)&&isvalid(sa)
                hide(sa);
            end
        end


        function initializeScopes(this,sampleInput,sampleOutput)
            [inData,outData]=selectDataChannels(this,sampleInput,sampleOutput);
            sampleScopeInput=[inData,outData];
            ts=this.TimeScope;
            if this.EnableTimeScope&&~isempty(ts)&&isvalid(ts)&&~isLocked(ts)
                setup(ts,sampleScopeInput);
            end
            sa=this.SpectrumAnalyzer;
            if this.EnableSpectrumAnalyzer&&~isempty(sa)&&isvalid(sa)&&~isLocked(sa)
                setup(sa,sampleScopeInput);
            end
        end

        function[inData,outData]=selectDataChannels(this,inData,outData)

            maxChans=this.MaxNumChannels;
            if size(inData,2)>maxChans
                inData=inData(:,1:maxChans);
            end
            inChanSelection=1:size(inData,2);

            if size(outData,2)>maxChans
                outData=outData(:,1:maxChans);
            end
            outChanSelection=1:size(outData,2);
            if~isequal(this.InputChannelSelection,inChanSelection)||...
                ~isequal(this.OutputChannelSelection,outChanSelection)
                this.InputChannelSelection=inChanSelection;
                this.OutputChannelSelection=outChanSelection;
                updateChannelNames(this)
            end
        end


        function updateChannelNames(this)
            inChanNames=arrayfun(@(x)getString(message('audio:audiotestbench:InputChannelN',x)),...
            this.InputChannelSelection,'UniformOutput',false);
            outChanNames=arrayfun(@(x)getString(message('audio:audiotestbench:OutputChannelN',x)),...
            this.OutputChannelSelection,'UniformOutput',false);
            channelNames=[inChanNames,outChanNames];


            ts=this.TimeScope;
            if~isempty(ts)&&isvalid(ts)
                ts.ChannelNames=channelNames;
            end

            sa=this.SpectrumAnalyzer;
            if~isempty(sa)&&isvalid(sa)
                sa.ChannelNames=channelNames;
            end
        end


        function addToScopesContainer(this,scopeObj)

            if this.UseScopesContainer
                containerTitle=getString(message('audio:audiotestbench:ScopesContainerTitle'));
                scopeObj.Docked=true;
                scopeObj.ContainerKey=containerTitle;
            end
        end


        function onTimeScopeVisibleChanged(this,~,~)

            if this.EnableTimeScope~=this.TimeScope.Visible
                this.EnableTimeScope=this.TimeScope.Visible;
                notify(this,'TimeScopeVisibleChanged')
            end
        end


        function onSpectrumAnalyzerVisibleChanged(this,~,~)

            if this.EnableSpectrumAnalyzer~=this.SpectrumAnalyzer.Visible
                this.EnableSpectrumAnalyzer=this.SpectrumAnalyzer.Visible;
                notify(this,'SpectrumAnalyzerVisibleChanged')
            end
        end


        function cacheAllSettings(this)
            settingsHandler=this.SettingsHandler;

            ts=this.TimeScope;
            if~isempty(ts)&&isvalid(ts)
                defStruct=this.TimeScopeDefaults;
                defStruct.Position=ts.Position;
                defStruct.ChannelNames=ts.ChannelNames;
                cacheObjectSettings(settingsHandler,'TimeScope',ts,defStruct);
            end

            sa=this.SpectrumAnalyzer;
            if~isempty(sa)&&isvalid(sa)
                defStruct=this.SpectrumAnalyzerDefaults;
                defStruct.Position=sa.Position;
                defStruct.ChannelNames=sa.ChannelNames;
                cacheObjectSettings(settingsHandler,'SpectrumAnalyzer',sa,defStruct);
            end
        end
    end


    methods(Static)
        function defObj=getDefaultScope(scopeType)

            Fs=44100;
            channelNames={getString(message('audio:audiotestbench:InputChannelN',1)),...
            getString(message('audio:audiotestbench:OutputChannelN',1))};
            defObj=[];
            if strcmp(scopeType,'TimeScope')
                defObj=timescope('SampleRate',Fs,...
                'TimeSpanSource','property','TimeSpan',1,...
                'BufferLength',Fs*4,...
                'TimeSpanOverrunAction','scroll',...
                'ChannelNames',channelNames,...
                'ShowLegend',true,'ShowGrid',true,'YLimits',[-1,1]);
            elseif strcmp(scopeType,'SpectrumAnalyzer')
                defObj=spectrumAnalyzer('SampleRate',Fs,...
                'AveragingMethod','exponential','ForgettingFactor',0.8,...
                'ChannelNames',channelNames,...
                'ShowLegend',true,'PlotAsTwoSidedSpectrum',false,...
                'FrequencyScale','log',...
                'ShowScreenMessages',false);
            end
        end


        function clearCachedSettings()
            settingsHandler=audio.app.internal.util.AppSettingsHandler('Audio','AudioTestBench');
            clearCachedSettings(settingsHandler,'TimeScope');
            clearCachedSettings(settingsHandler,'SpectrumAnalyzer');
        end
    end
end
