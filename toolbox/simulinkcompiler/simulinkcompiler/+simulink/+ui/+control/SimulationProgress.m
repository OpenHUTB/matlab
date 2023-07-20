classdef SimulationProgress<simulink.internal.SLComponent




    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
        'Started',...
        'Stopped',...
'Paused'...
        }
    end

    properties(Access=public,SetObservable)

        Color{validateattributes(Color,{'double'},{'<=',1,'>=',0,'size',[1,3]})}=[0,0.4470,0.7410]
        FontColor{validateattributes(FontColor,{'double'},{'<=',1,'>=',0,'size',[1,3]})}=[0,0,0]
        ShowSimTime(1,1)matlab.lang.OnOffSwitchState=matlab.lang.OnOffSwitchState.on
        ShowElapsedTime(1,1)matlab.lang.OnOffSwitchState=matlab.lang.OnOffSwitchState.on
    end

    properties(Access={?simulink.internal.SLComponent},Transient,NonCopyable)
        ProgressBar matlab.ui.control.HTML
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

PostStartedListener
PostStoppedListener

SimulationTimeChangedListener

SimStartWallClockTime
        TotalElapsedWCTime=0;
    end

    methods(Access=protected)
        function setup(obj)


            barWidth=200;
            barHeight=44;



            obj.Grid=uigridlayout(obj,[1,1],...
            'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
            obj.Grid.ColumnWidth={'1x'};
            obj.Grid.RowHeight={'1x'};


            obj.ProgressBar=uihtml(obj.Grid);
            obj.ProgressBar.Layout.Row=1;
            obj.ProgressBar.Layout.Column=1;



            obj.ProgressBar.HTMLSource='progressbar.html';
            obj.ProgressBar.Data.State='idle';
            obj.ProgressBar.Data.Progress=0;
            obj.ProgressBar.Data.Time="";
            obj.ProgressBar.Data.WCTime="";
            obj.ProgressBar.Data.ProgressColor=obj.Color;
            obj.ProgressBar.Data.FontColor=obj.FontColor;
            obj.ProgressBar.Data.BackgroundColor=obj.BackgroundColor;

            obj.Position=[100,100,barWidth,barHeight];




            obj.tgListenerCreate=@obj.createListeners;
            obj.tgListenerDestroy=@obj.destroyListeners;

            addlistener(obj,'ShowSimTime','PostSet',@(src,event)obj.handleSimTimeUpdated());
        end

        function update(obj)
            if obj.firstUpdate
                obj.firstUpdate=false;



                if isempty(obj.GetTargetNameFcnH)
                    obj.initTarget([]);
                end
            elseif obj.ShowElapsedTime&&obj.ProgressBar.Data.WCTime==""
                obj.ProgressBar.Data.WCTime=message('simulinkcompiler:simulink_components:InitialElapsedTime').getString();
            end

            obj.updateTheme();

            if~obj.isDesignTime()

                obj.verifyTargetIsInitialised();
                obj.updateGUI([]);
            end

            drawnow limitrate;
        end
    end

    methods(Access=private)
        function destroyListeners(obj)
            delete(obj.SimulationTimeChangedListener);
            obj.SimulationTimeChangedListener=[];

            delete(obj.PostStartedListener);
            obj.PostStartedListener=[];

            delete(obj.PostStoppedListener);
            obj.PostStoppedListener=[];
        end

        function createListeners(obj)
            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty(),return;end

            obj.SimulationTimeChangedListener=listener(tg,'SimulationTimeChanged',...
            @(src,evnt)updateProgressBar(obj,evnt));

            obj.PostStoppedListener=listener(tg,'PostStopped',...
            @(src,evnt)targetPostStopped(obj,evnt));
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(obj)
            obj.ProgressBar.Tooltip=message('simulinkcompiler:simulink_components:InvalidTargetTooltip',...
            obj.GetTargetNameFcnH()).getString();
            obj.ProgressBar.Data.State='disabled';

        end

        function enableControlForValidTarget(obj)
            obj.ProgressBar.Data.State='idle';
            obj.ProgressBar.Tooltip=message('simulinkcompiler:simulink_components:SimulationProgressTooltip').getString();
        end

        function updateGUI(obj,~)






            if obj.firstUpdate
                obj.update();
                drawnow limitrate;
                return;
            end

            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty(),return;end

            if obj.simTimeDisplayCondSatisfied&&obj.ProgressBar.Data.Time==""
                obj.ProgressBar.Data.Time="T = 00:00:00";
            end

            obj.ProgressBar.Data.ProgressColor=obj.Color;

            obj.ProgressBar.Tooltip=message('simulinkcompiler:simulink_components:SimulationProgressTooltip').getString();


            if tg.isConnected()


                isLoaded=tg.isLoaded();
                if tg.isPaused()
                    if~isfinite(tg.StopTime)
                        obj.ProgressBar.Data.State='indeterminate-paused';
                    end

                    if~isempty(obj.SimStartWallClockTime)
                        obj.TotalElapsedWCTime=toc(obj.SimStartWallClockTime)+obj.TotalElapsedWCTime;
                    end
                    obj.SimStartWallClockTime=[];

                elseif isLoaded

                    obj.ProgressBar.Data.State='idle';
                end
            end

            notify(obj,'GUIUpdated');
        end
    end

    methods(Access=private)

        function updateTheme(obj)
            obj.ProgressBar.Data.ProgressColor=obj.Color;
            obj.ProgressBar.Data.FontColor=obj.FontColor;
            obj.ProgressBar.Data.BackgroundColor=obj.BackgroundColor;
            drawnow limitrate;
        end

        function TF=simTimeDisplayCondSatisfied(obj)
            TF=false;

            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty(),return;end

            stopTime=str2num(tg.SimulationInput.getModelParameter('StopTime'));%#ok<ST2NM> 
            TF=isfinite(stopTime)&&obj.ShowSimTime;
        end

        function updateProgressBar(obj,evtData)
            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty(),return;end

            obj.ProgressBar.Data.ProgressColor=obj.Color;

            stopTime=str2num(tg.SimulationInput.getModelParameter('StopTime'));
            simTime=evtData.NewTime;

            if isempty(obj.SimStartWallClockTime)
                obj.SimStartWallClockTime=tic;
            end

            obj.ProgressBar.Data.Time="";
            obj.ProgressBar.Data.WCTime="";

            if obj.ShowElapsedTime
                obj.setWallClockString();
            end

            if isfinite(stopTime)&&isfinite(simTime)&&simTime>0
                progress=single(evtData.NewTime)/stopTime;
                obj.ProgressBar.Data.State='determinate';
                obj.ProgressBar.Data.Progress=progress;

                if obj.ShowSimTime
                    obj.buildSimTimeString(simTime);
                end

            elseif~isfinite(stopTime)
                obj.ProgressBar.Data.State='indeterminate';
            end
        end

        function buildSimTimeString(obj,simTime)
            prefix=message('simulinkcompiler:simulink_components:SimulationTimePrefix').getString();
            [simTimeStr,days]=convertSecondsToDHMSFormat(simTime);

            if days>99
                prefix=message('simulinkcompiler:simulink_components:SimTimeGreaterThan').getString();
                simTimeStr=message('simulinkcompiler:simulink_components:SimProgressMaxDays').getString();
            end

            simTimeStr=sprintf('%s %s',prefix,simTimeStr);
            obj.ProgressBar.Data.Time=simTimeStr;
        end

        function setWallClockString(obj)
            wallClockTime=toc(obj.SimStartWallClockTime)+obj.TotalElapsedWCTime;
            prefix="Elapsed time = ";
            [wallClockTimeStr,days]=convertSecondsToDHMSFormat(wallClockTime);

            if days>99
                prefix="Elapsed time >";
                wallClockTimeStr="99 days";
            end

            wallClockTimeStr=sprintf('%s %s',prefix,wallClockTimeStr);
            obj.ProgressBar.Data.WCTime=wallClockTimeStr;
        end

        function targetPostStopped(obj,~)
            obj.TotalElapsedWCTime=0;
            obj.SimStartWallClockTime=[];
            obj.ProgressBar.Data.WCTime="";
            obj.ProgressBar.Data.Time="";

            if obj.simTimeDisplayCondSatisfied
                obj.ProgressBar.Data.Time="T = 00:00:00";
            end

            if obj.ShowElapsedTime
                obj.ProgressBar.Data.WCTime="Elapsed time: 00:00:00";
            end
        end

        function handleSimTimeUpdated(obj)
            if~obj.ShowSimTime
                obj.ProgressBar.Data.Time="";
            end
        end
    end
end

function[durationStr,days]=convertSecondsToDHMSFormat(seconds)
    days=floor(seconds/86400);
    secs=mod(seconds,86400);

    hours=floor(secs/3600);
    secs=mod(secs,3600);

    mins=floor(secs/60);
    secs=mod(secs,60);

    if days>0

        daysStr="day";
        hoursStr="hour";

        if days>1,daysStr="days";end
        if hours>1,hoursStr="hours";end

        durationStr=sprintf('%02d %s %02d %s',days,daysStr,hours,hoursStr);
    else
        durationStr=sprintf('%02d:%02d:%1.0f',hours,mins,secs);
    end
end
