classdef StatusBar<slrealtime.internal.SLRTComponent

    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
'Stopped'
        }
    end

    methods(Access=public)
        function delete(this)
            this.destroyTCListeners();
        end
    end

    properties(Access=public)


FontName
FontSize
FontWeight
FontAngle
FontColor
    end

    properties(Access={?slrealtime.internal.SLRTComponent},Transient,NonCopyable)
        StatusLabel matlab.ui.control.Label
        TimeLabel matlab.ui.control.Label
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

SimTimeListener
StatusListener
    end

    methods(Access=private)
        function destroyTCListeners(this)
            delete(this.SimTimeListener);
            this.SimTimeListener=[];

            delete(this.StatusListener);
            this.StatusListener=[];
        end

        function createTCListeners(this)
            function modelStateCB(evnt)
                if isempty(evnt.AffectedObject.ModelState)
                    this.StatusLabel.Text='';
                else
                    this.StatusLabel.Text=[char(evnt.AffectedObject.ModelState),': ',char(evnt.AffectedObject.ModelProperties.Application)];
                end
            end
            function modelExecPropertiesCB(evnt)
                execTime=evnt.AffectedObject.ModelExecProperties.ExecTime;
                if~isequal(execTime,0)
                    this.TimeLabel.Text=['T=',num2str(execTime)];
                else
                    this.TimeLabel.Text='';
                end
            end

            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            this.SimTimeListener=listener(tg.get('tc'),'ModelExecProperties',...
            'PostSet',@(src,evnt)modelExecPropertiesCB(evnt));

            this.StatusListener=listener(tg.get('tc'),'ModelState',...
            'PostSet',@(src,evnt)modelStateCB(evnt));
        end
    end

    methods(Access=protected)
        function setup(this)


            width=400;
            height=30;



            this.Grid=uigridlayout(this,[1,2],...
            'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
            this.Grid.ColumnWidth={'2x','1x'};
            this.Grid.RowHeight={'1x'};



            this.StatusLabel=uilabel(this.Grid);
            this.StatusLabel.Layout.Row=1;
            this.StatusLabel.Layout.Column=1;
            this.StatusLabel.Text='';

            this.TimeLabel=uilabel(this.Grid);
            this.TimeLabel.Layout.Row=1;
            this.TimeLabel.Layout.Column=2;
            this.TimeLabel.Text='';



            this.Position=[100,100,width,height];
            this.FontName=this.StatusLabel.FontName;
            this.FontSize=this.StatusLabel.FontSize;
            this.FontWeight=this.StatusLabel.FontWeight;
            this.FontAngle=this.StatusLabel.FontAngle;
            this.FontColor=this.StatusLabel.FontColor;



            this.tgListenerCreate=@this.createTCListeners;
            this.tgListenerDestroy=@this.destroyTCListeners;
        end

        function update(this)
            if this.firstUpdate
                this.firstUpdate=false;



                if isempty(this.GetTargetNameFcnH)
                    this.initTarget([]);
                end
            end

            this.StatusLabel.FontName=this.FontName;
            this.StatusLabel.FontSize=this.FontSize;
            this.StatusLabel.FontWeight=this.FontWeight;
            this.StatusLabel.FontAngle=this.FontAngle;
            this.StatusLabel.FontColor=this.FontColor;
            this.StatusLabel.BackgroundColor=this.BackgroundColor;

            this.TimeLabel.FontName=this.FontName;
            this.TimeLabel.FontSize=this.FontSize;
            this.TimeLabel.FontWeight=this.FontWeight;
            this.TimeLabel.FontAngle=this.FontAngle;
            this.TimeLabel.FontColor=this.FontColor;
            this.TimeLabel.BackgroundColor=this.BackgroundColor;

            if this.isDesignTime()

                this.StatusLabel.Text=message('slrealtime:appdesigner:Unloaded').getString();
                this.TimeLabel.Text='T=0';
            end
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)
            this.disableStatusBar();
        end

        function updateGUI(this,~)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end



            if isempty(tg.ModelStatus)||isempty(tg.ModelStatus.State)
                this.disableStatusBar();
            else
                this.StatusLabel.Text=[char(tg.ModelStatus.State),': ',char(tg.ModelStatus.Application)];

                execTime=tg.ModelStatus.ExecTime;
                if~isequal(execTime,0)
                    this.TimeLabel.Text=['T=',num2str(execTime)];
                else
                    this.TimeLabel.Text='';
                end
            end
        end
    end

    methods(Access=private)
        function disableStatusBar(this)
            this.StatusLabel.Text=message('slrealtime:appdesigner:Unloaded').getString();
            this.TimeLabel.Text='';
        end
    end
end