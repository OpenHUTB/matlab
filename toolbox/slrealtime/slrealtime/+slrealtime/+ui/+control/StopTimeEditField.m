classdef StopTimeEditField<slrealtime.internal.SLRTComponent

    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
        'Started',...
        'Stopped',...
'StopTimeChanged'...
        }
    end

    properties(Access=public)


FontName
FontSize
FontWeight
FontAngle
FontColor
    end

    properties(Access={?slrealtime.internal.SLRTComponent},Transient,NonCopyable)
        EditField matlab.ui.control.NumericEditField
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout
    end

    methods(Access=protected)
        function setup(this)


            editWidth=55;
            editHeight=20;



            this.Grid=uigridlayout(this,[1,1],...
            'ColumnSpacing',0,'RowSpacing',0,'Padding',0);
            this.Grid.ColumnWidth={'1x'};
            this.Grid.RowHeight={'1x'};



            this.EditField=uieditfield(this.Grid,'numeric',...
            'ValueChangedFcn',@(o,e)this.stopTimeValueChanged(e));
            this.EditField.Layout.Row=1;
            this.EditField.Layout.Column=1;
            this.EditField.Limits=[0,Inf];



            this.Position=[100,100,editWidth,editHeight];
            this.FontName=this.EditField.FontName;
            this.FontSize=this.EditField.FontSize;
            this.FontWeight=this.EditField.FontWeight;
            this.FontAngle=this.EditField.FontAngle;
            this.FontColor=this.EditField.FontColor;
            this.BackgroundColor=this.EditField.BackgroundColor;
        end

        function update(this)
            if this.firstUpdate
                this.firstUpdate=false;



                if isempty(this.GetTargetNameFcnH)
                    this.initTarget([]);
                end
            end

            this.EditField.FontName=this.FontName;
            this.EditField.FontSize=this.FontSize;
            this.EditField.FontWeight=this.FontWeight;
            this.EditField.FontAngle=this.FontAngle;
            this.EditField.FontColor=this.FontColor;
            this.EditField.BackgroundColor=this.BackgroundColor;

            if this.isDesignTime()

                this.EditField.Enable='on';
                this.EditField.Tooltip='';
            end
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)
            this.EditField.Enable='off';
            this.EditField.Value=Inf;
            this.EditField.Tooltip=message('slrealtime:appdesigner:InvalidTargetTooltip',...
            this.GetTargetNameFcnH()).getString();
        end

        function updateGUI(this,evnt)
            stoptime=[];
            if~isempty(evnt)
                if isa(evnt,'slrealtime.events.TargetLoadedData')







                    stoptime=evnt.StopTime;
                elseif isa(evnt,'slrealtime.events.TargetStopTimeData')
                    stoptime=evnt.stoptime;
                end
            end

            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            if tg.isConnected()


                [isLoaded,loadedApp]=tg.isLoaded();
                isRunning=tg.isRunning();

                if isRunning

                    this.EditField.Enable='off';
                    this.EditField.Tooltip='';
                    if isempty(stoptime)
                        stoptime=tg.ModelStatus.StopTime;
                    end
                    this.EditField.Value=stoptime;

                elseif isLoaded

                    this.EditField.Enable='on';
                    this.EditField.Tooltip=message('slrealtime:appdesigner:StopTimeTooltip',loadedApp,this.GetTargetNameFcnH()).getString();
                    if isempty(stoptime)
                        stoptime=tg.ModelStatus.StopTime;
                    end
                    this.EditField.Value=stoptime;

                else

                    this.EditField.Enable='off';
                    this.EditField.Tooltip='';
                    this.EditField.Value=Inf;
                end
            else

                this.EditField.Enable='off';
                this.EditField.Tooltip='';
                this.EditField.Value=Inf;
            end
        end
    end

    methods(Access=private)
        function stopTimeValueChanged(this,e)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            try
                tg.setStopTime(e.Value);
            catch ME
                this.EditField(e.PreviousValue);
                this.uialert(ME);
                return;
            end
        end
    end
end