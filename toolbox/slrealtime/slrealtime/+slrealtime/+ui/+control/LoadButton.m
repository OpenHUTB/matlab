classdef LoadButton<slrealtime.internal.SLRTComponent

    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
        'LoadFailed',...
'Started'...
        ,'Stopped'...
        }
    end

    methods(Access=public)
        function delete(this)
            delete(this.LoadApplicationUIFigure);
        end
    end

    properties(Access=public)
        LoadIcon='slrtLoadIcon.png';
        LoadText=message('slrealtime:appdesigner:LoadAppLabel').getString();

        ShowLoadedApplication=true;

        SkipInstall=false;
        AsyncLoad=false;
        Application{validateApplication(Application)}=''



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
        Button matlab.ui.control.Button
        Label matlab.ui.control.Label
    end

    properties(Access={?slrealtime.internal.SLRTComponent},Transient,NonCopyable)
LoadApplicationUIFigure
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

PostLoadedListener

GridColWidth
GridRowHeight
    end

    methods(Access=protected)
        function setup(this)


            columnWidth=100;
            buttonHeight=60;
            statusHeight=30;
            rowSpacing=2;



            this.GridColWidth={'1x'};
            this.GridRowHeight={'2x','1x'};
            this.Grid=uigridlayout(this,[2,1],...
            'Padding',0,'RowSpacing',rowSpacing,'ColumnSpacing',0);
            this.Grid.ColumnWidth=this.GridColWidth;
            this.Grid.RowHeight=this.GridRowHeight;



            this.Button=uibutton(this.Grid,...
            'ButtonPushedFcn',@(o,e)this.buttonPushed());
            this.Button.Layout.Row=1;
            this.Button.Layout.Column=1;
            this.Button.IconAlignment='top';



            this.Label=uilabel(this.Grid);
            this.Label.Layout.Row=2;
            this.Label.Layout.Column=1;
            this.Label.VerticalAlignment='top';
            this.Label.HorizontalAlignment='center';



            this.Position=[100,100,columnWidth,buttonHeight+rowSpacing+statusHeight];
            this.FontName=this.Button.FontName;
            this.FontSize=this.Button.FontSize;
            this.FontWeight=this.Button.FontWeight;
            this.FontAngle=this.Button.FontAngle;
            this.FontColor=this.Button.FontColor;
            this.IconAlignment=this.Button.IconAlignment;
            this.HorizontalAlignment=this.Button.HorizontalAlignment;
            this.VerticalAlignment=this.Button.VerticalAlignment;
            this.BackgroundColor=this.Button.BackgroundColor;




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

            if this.ShowLoadedApplication
                this.Grid.RowHeight=this.GridRowHeight;
            else
                this.Grid.RowHeight={'1x',0};
            end
            this.Label.Visible=this.ShowLoadedApplication;

            this.Button.FontName=this.FontName;
            this.Button.FontSize=this.FontSize;
            this.Button.FontWeight=this.FontWeight;
            this.Button.FontAngle=this.FontAngle;
            this.Button.FontColor=this.FontColor;

            this.Label.FontName=this.FontName;
            this.Label.FontSize=this.FontSize;
            this.Label.FontWeight=this.FontWeight;
            this.Label.FontAngle=this.FontAngle;
            this.Label.FontColor=this.FontColor;

            this.Button.IconAlignment=this.IconAlignment;
            this.Button.HorizontalAlignment=this.HorizontalAlignment;
            this.Button.VerticalAlignment=this.VerticalAlignment;

            this.Button.BackgroundColor=this.BackgroundColor;

            if this.isDesignTime()

                this.Button.Enable='on';
                this.Button.Text=this.LoadText;
                this.Button.Icon=this.LoadIcon;
                this.Button.Tooltip='';
                this.Label.Enable='on';
                this.Label.Text={message('slrealtime:appdesigner:Unloaded').getString()};
                this.Label.Tooltip='';
            else

                this.updateGUI([]);
            end
        end
    end

    methods(Access=private)
        function destroyListeners(this)
            delete(this.PostLoadedListener);
            this.PostLoadedListener=[];
        end

        function createListeners(this)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            this.PostLoadedListener=listener(tg,'PostLoaded',...
            @(src,evnt)closeProgressDlg(this));
        end
    end

    methods
        function set.LoadIcon(this,value)
            slrealtime.internal.SLRTComponent.validateImageFile('LoadIcon',value);
            this.LoadIcon=value;
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)
            this.Button.Enable='off';
            this.Button.Tooltip=message('slrealtime:appdesigner:InvalidTargetTooltip',...
            this.GetTargetNameFcnH()).getString();
            this.Label.Enable='off';
            this.Label.Text='';
            this.Label.Tooltip='';
        end

        function updateGUI(this,~)
            this.Button.Icon=this.LoadIcon;

            if this.isSimulinkNormalMode()
                this.Button.Text=message('slrealtime:appdesigner:LoadModelLabel').getString();
            else
                this.Button.Text=this.LoadText;
            end

            tg=this.tgGetTargetObject();
            if isempty(tg),return;end
            targetName=this.GetTargetNameFcnH();

            if tg.isConnected()

                this.Button.Enable='on';
                this.Label.Enable='on';

                [isLoaded,loadedApp]=tg.isLoaded();
                [isRunning,runningApp]=tg.isRunning();

                if isRunning

                    this.Button.Enable='off';
                    this.Button.Tooltip='';
                    this.Label.Enable='off';
                    this.Label.Text={runningApp};
                    this.Label.Tooltip='';
                elseif isLoaded

                    this.Button.Enable='on';
                    if this.isSimulinkNormalMode()
                        if isempty(this.Application)
                            this.Button.Tooltip=message('slrealtime:appdesigner:LoadModelTooltip').getString();
                        else
                            this.Button.Tooltip=message('slrealtime:appdesigner:LoadSpecificModelTooltip',this.Application).getString();
                        end
                        this.Label.Tooltip=message('slrealtime:appdesigner:LoadedModelTooltip',loadedApp).getString();
                    else
                        if isempty(this.Application)
                            this.Button.Tooltip=message('slrealtime:appdesigner:LoadAppTooltip',targetName).getString();
                        else
                            this.Button.Tooltip=message('slrealtime:appdesigner:LoadSpecificAppTooltip',this.Application,targetName).getString();
                        end
                        this.Label.Tooltip=message('slrealtime:appdesigner:LoadedAppTooltip',loadedApp,targetName).getString();
                    end
                    this.Label.Enable='on';
                    this.Label.Text={loadedApp};
                else

                    this.Button.Enable='on';
                    if this.isSimulinkNormalMode()
                        if isempty(this.Application)
                            this.Button.Tooltip=message('slrealtime:appdesigner:LoadModelTooltip').getString();
                        else
                            this.Button.Tooltip=message('slrealtime:appdesigner:LoadSpecificModelTooltip',this.Application).getString();
                        end
                        this.Label.Tooltip=message('slrealtime:appdesigner:LoadedModelUnloadedTooltip').getString();
                    else
                        if isempty(this.Application)
                            this.Button.Tooltip=message('slrealtime:appdesigner:LoadAppTooltip',targetName).getString();
                        else
                            this.Button.Tooltip=message('slrealtime:appdesigner:LoadSpecificAppTooltip',this.Application,targetName).getString();
                        end
                        this.Label.Tooltip=message('slrealtime:appdesigner:LoadedAppUnloadedTooltip',targetName).getString();
                    end
                    this.Label.Enable='on';
                    this.Label.Text={message('slrealtime:appdesigner:Unloaded').getString()};
                end
            else

                this.Button.Enable='off';
                this.Button.Tooltip='';
                this.Label.Enable='off';
                this.Label.Text='';
                this.Label.Tooltip='';
            end

            notify(this,'GUIUpdated');
        end
    end

    methods(Access={?slrealtime.ui.container.Menu})
        function buttonPushed(this)
            if this.isSimulinkNormalMode()
                name=[];
                if~isempty(this.Application)
                    name=this.Application;
                else
                    [filename]=uigetfile(...
                    '*.mdl;*.slx',getString(message('MATLAB:uistring:uiopen:ModelFiles')));
                    figure(ancestor(this.Parent,'figure'));
                    if filename
                        [~,name,~]=fileparts(filename);
                    end
                end
                if~isempty(name)
                    tg=this.tgGetTargetObject();
                    if isempty(tg),return;end

                    this.uiwarning(message('slrealtime:appdesigner:NormalModeLoadWarning').getString());

                    targetName=this.GetTargetNameFcnH();
                    this.openProgressDlg(...
                    message('slrealtime:appdesigner:Loading').getString(),...
                    message('slrealtime:appdesigner:LoadingOnTarget',name,targetName).getString());

                    try
                        tg.load(name);
                    catch ME
                        this.closeProgressDlg();
                        this.uialert(ME);
                        return;
                    end
                end
            elseif~isempty(this.Application)
                this.FinishLoadApplicationButtonPushed(false,this.Application,[]);
            else
                this.LoadApplicationUIFigure=...
                slrealtime.internal.guis.Explorer.LoadApplicationDialog(...
                ancestor(this.Parent,'figure'),...
                this.GetTargetNameFcnH(),...
                @(loadFromTarget,name,pathname)this.FinishLoadApplicationButtonPushed(loadFromTarget,name,pathname));
            end
        end
    end

    methods(Access=public)
        function FinishLoadApplicationButtonPushed(this,loadFromTarget,name,pathname)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            targetName=this.GetTargetNameFcnH();

            args={};
            if this.SkipInstall||loadFromTarget
                args{end+1}='SkipInstall';
                args{end+1}=true;
            end

            if~this.AsyncLoad
                this.openProgressDlg(...
                message('slrealtime:appdesigner:Loading').getString(),...
                message('slrealtime:appdesigner:LoadingOnTarget',name,targetName).getString());
            else


                stoppedListener=this.tgEventListenersTriggeringUpdateGUI('Stopped');
                stoppedListener.Enabled=false;
                this.Label.Text={message('slrealtime:appdesigner:LoadingAsyncStatus').getString()};

                args{end+1}='AsynchronousLoad';
                args{end+1}=true;
            end

            try
                tg.load(fullfile(pathname,name),args{:});
            catch ME
                this.closeProgressDlg();
                stoppedListener=this.tgEventListenersTriggeringUpdateGUI('Stopped');
                stoppedListener.Enabled=true;

                this.uialert(ME);
                return;
            end
            stoppedListener=this.tgEventListenersTriggeringUpdateGUI('Stopped');
            stoppedListener.Enabled=true;
        end
    end
end

function validateApplication(prop)

    if isempty(prop),return;end


    mustBeTextScalar(prop);
end