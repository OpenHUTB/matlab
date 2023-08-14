classdef StartStopButton<slrealtime.internal.SLRTComponent

    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
        'Started',...
'Stopped'...
        }
    end

    properties(Access=public)
        StartIcon='slrtRunIcon.png';
        StopIcon='slrtStopIcon.png';

        StartText=message('slrealtime:appdesigner:Start').getString()
        StopText=message('slrealtime:appdesigner:Stop').getString()

        ReloadOnStop(1,1)logical=true
        AutoImportFileLog(1,1)logical=true
        ExportToBaseWorkspace(1,1)logical=true



FontName
FontSize
FontWeight
FontAngle
FontColor
IconAlignment
HorizontalAlignment
VerticalAlignment
    end

    properties(Access={?slrealtime.ui.container.Menu,?slrealtime.internal.SLRTComponent},Transient,NonCopyable)
        StartButton matlab.ui.control.Button
        StopButton matlab.ui.control.Button
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

PostStartedListener
PostStoppedListener
    end

    methods(Access=protected)
        function setup(this)


            buttonWidth=54;
            buttonHeight=54;



            this.Grid=uigridlayout(this,[1,1],...
            'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
            this.Grid.ColumnWidth={'1x'};
            this.Grid.RowHeight={'1x'};



            this.StopButton=uibutton(this.Grid,...
            'ButtonPushedFcn',@(o,e)this.stopButtonPushed());
            this.StopButton.Layout.Row=1;
            this.StopButton.Layout.Column=1;
            this.StopButton.IconAlignment='top';



            this.StartButton=uibutton(this.Grid,...
            'ButtonPushedFcn',@(o,e)this.startButtonPushed());
            this.StartButton.Layout.Row=this.StopButton.Layout.Row;
            this.StartButton.Layout.Column=this.StopButton.Layout.Column;
            this.StartButton.IconAlignment=this.StopButton.IconAlignment;



            this.Position=[100,100,buttonWidth,buttonHeight];
            this.FontName=this.StartButton.FontName;
            this.FontSize=this.StartButton.FontSize;
            this.FontWeight=this.StartButton.FontWeight;
            this.FontAngle=this.StartButton.FontAngle;
            this.FontColor=this.StartButton.FontColor;
            this.IconAlignment=this.StartButton.IconAlignment;
            this.HorizontalAlignment=this.StartButton.HorizontalAlignment;
            this.VerticalAlignment=this.StartButton.VerticalAlignment;
            this.BackgroundColor=this.StartButton.BackgroundColor;




            this.tgListenerCreate=@this.createListeners;
            this.tgListenerDestroy=@this.destroyListeners;
        end

        function update(this)
            if this.firstUpdate
                this.firstUpdate=false;



                if isempty(this.GetTargetNameFcnH)
                    this.initTarget([]);
                end
            end

            this.StartButton.FontName=this.FontName;
            this.StartButton.FontSize=this.FontSize;
            this.StartButton.FontWeight=this.FontWeight;
            this.StartButton.FontAngle=this.FontAngle;
            this.StartButton.FontColor=this.FontColor;
            this.StartButton.IconAlignment=this.IconAlignment;
            this.StartButton.HorizontalAlignment=this.HorizontalAlignment;
            this.StartButton.VerticalAlignment=this.VerticalAlignment;
            this.StartButton.BackgroundColor=this.BackgroundColor;

            this.StopButton.FontName=this.FontName;
            this.StopButton.FontSize=this.FontSize;
            this.StopButton.FontWeight=this.FontWeight;
            this.StopButton.FontAngle=this.FontAngle;
            this.StopButton.FontColor=this.FontColor;
            this.StopButton.IconAlignment=this.IconAlignment;
            this.StopButton.HorizontalAlignment=this.HorizontalAlignment;
            this.StopButton.VerticalAlignment=this.VerticalAlignment;
            this.StopButton.BackgroundColor=this.BackgroundColor;

            this.StartButton.Icon=this.StartIcon;
            this.StopButton.Icon=this.StopIcon;
            this.StartButton.Text=this.StartText;
            this.StopButton.Text=this.StopText;

            if this.isDesignTime()

                this.StartButton.Enable='on';
                this.StartButton.Visible='on';
                this.StartButton.Tooltip='';
                this.StopButton.Enable='off';
                this.StopButton.Visible='off';
                this.StopButton.Tooltip='';
            else

                this.updateGUI([]);
            end
        end
    end

    methods(Access=private)
        function destroyListeners(this)
            delete(this.PostStartedListener);
            this.PostStartedListener=[];

            delete(this.PostStoppedListener);
            this.PostStoppedListener=[];
        end

        function createListeners(this)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            this.PostStartedListener=listener(tg,'PostStarted',...
            @(src,evnt)closeProgressDlg(this));

            this.PostStoppedListener=listener(tg,'PostStopped',...
            @(src,evnt)closeProgressDlg(this));
        end
    end

    methods
        function set.StartIcon(this,value)
            slrealtime.internal.SLRTComponent.validateImageFile('StartIcon',value);
            this.StartIcon=value;
        end

        function set.StopIcon(this,value)
            slrealtime.internal.SLRTComponent.validateImageFile('StopIcon',value);
            this.StopIcon=value;
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)
            this.StartButton.Enable='off';
            this.StartButton.Visible='on';
            this.StartButton.Tooltip=message('slrealtime:appdesigner:InvalidTargetTooltip',...
            this.GetTargetNameFcnH()).getString();
            this.StopButton.Enable='off';
            this.StopButton.Visible='off';
        end

        function updateGUI(this,~)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end
            targetName=this.GetTargetNameFcnH();

            if tg.isConnected()


                [isLoaded,loadedApp]=tg.isLoaded();
                [isRunning,runningApp]=tg.isRunning();

                if isRunning

                    this.StartButton.Enable='off';
                    this.StartButton.Visible='off';
                    this.StartButton.Tooltip='';
                    this.StopButton.Enable='on';
                    this.StopButton.Visible='on';
                    this.StopButton.Tooltip=message('slrealtime:appdesigner:StopAppOnTarget',runningApp,targetName).getString();

                elseif isLoaded

                    this.StartButton.Enable='on';
                    this.StartButton.Visible='on';
                    this.StartButton.Tooltip=message('slrealtime:appdesigner:StartAppOnTarget',loadedApp,targetName).getString();
                    this.StopButton.Enable='off';
                    this.StopButton.Visible='off';
                    this.StopButton.Tooltip='';

                else

                    this.StartButton.Enable='off';
                    this.StartButton.Visible='on';
                    this.StartButton.Tooltip='';
                    this.StopButton.Enable='off';
                    this.StopButton.Visible='off';
                    this.StopButton.Tooltip='';
                end
            else

                this.StartButton.Enable='off';
                this.StartButton.Visible='on';
                this.StartButton.Tooltip='';
                this.StopButton.Enable='off';
                this.StopButton.Visible='off';
                this.StopButton.Tooltip='';
            end

            notify(this,'GUIUpdated');
        end
    end

    methods(Access={?slrealtime.ui.container.Menu})
        function startButtonPushed(this)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            targetName=this.GetTargetNameFcnH();

            args={};
            args{end+1}='ReloadOnStop';
            args{end+1}=this.ReloadOnStop;
            args{end+1}='AutoImportFileLog';
            args{end+1}=this.AutoImportFileLog;
            args{end+1}='ExportToBaseWorkspace';
            args{end+1}=this.ExportToBaseWorkspace;

            [~,loadedApp]=tg.isLoaded();
            this.openProgressDlg(...
            message('slrealtime:appdesigner:Starting').getString(),...
            message('slrealtime:appdesigner:StartingApp',loadedApp,targetName).getString());

            try
                tg.start(args{:});
            catch ME
                this.closeProgressDlg();
                this.uialert(ME);
                return;
            end
        end

        function stopButtonPushed(this)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            targetName=this.GetTargetNameFcnH();

            [~,runningApp]=tg.isRunning();
            this.openProgressDlg(...
            message('slrealtime:appdesigner:Stopping').getString(),...
            message('slrealtime:appdesigner:StoppingApp',runningApp,targetName).getString());

            try
                tg.stop();
            catch ME
                this.closeProgressDlg();
                this.uialert(ME);
                return;
            end
        end
    end
end