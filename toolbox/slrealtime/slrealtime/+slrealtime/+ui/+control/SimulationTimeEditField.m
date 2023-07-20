classdef SimulationTimeEditField<slrealtime.internal.SLRTComponent

    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
        'Started',...
'Stopped'
        }
    end

    methods(Access=public)
        function delete(this)
            this.destroySimTimeListener();
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
        EditField matlab.ui.control.NumericEditField
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

SimTimeListener
    end

    methods(Access=private)
        function destroySimTimeListener(this)
            delete(this.SimTimeListener);
            this.SimTimeListener=[];
        end

        function createSimTimeListener(this)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            this.SimTimeListener=listener(tg.get('tc'),'ModelExecProperties',...
            'PostSet',@(src,evnt)this.EditField.set('Value',evnt.AffectedObject.ModelExecProperties.ExecTime));
        end
    end

    methods(Access=protected)
        function setup(this)


            editWidth=90;
            editHeight=20;



            this.Grid=uigridlayout(this,[1,1],...
            'ColumnSpacing',0,'RowSpacing',0,'Padding',0);
            this.Grid.ColumnWidth={'1x'};
            this.Grid.RowHeight={'1x'};



            this.EditField=uieditfield(this.Grid,'numeric');
            this.EditField.Layout.Row=1;
            this.EditField.Layout.Column=1;
            this.EditField.Editable='off';
            this.EditField.Value=0;



            this.Position=[100,100,editWidth,editHeight];
            this.FontName=this.EditField.FontName;
            this.FontSize=this.EditField.FontSize;
            this.FontWeight=this.EditField.FontWeight;
            this.FontAngle=this.EditField.FontAngle;
            this.FontColor=this.EditField.FontColor;
            this.BackgroundColor=this.EditField.BackgroundColor;







            this.Interruptible=false;



            this.tgListenerCreate=@this.createSimTimeListener;
            this.tgListenerDestroy=@this.destroySimTimeListener;
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
            this.EditField.Value=0;
            this.EditField.Tooltip=message('slrealtime:appdesigner:InvalidTargetTooltip',...
            this.GetTargetNameFcnH()).getString();
        end

        function updateGUI(this,~)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            if tg.isConnected()


                isLoaded=tg.isLoaded();
                [isRunning,runningApp]=tg.isRunning();

                if isRunning

                    this.EditField.Enable='on';
                    this.EditField.Tooltip=message('slrealtime:appdesigner:SimulationTimeTooltip',runningApp,this.GetTargetNameFcnH()).getString();

                elseif isLoaded

                    this.EditField.Enable='off';
                    this.EditField.Tooltip='';
                    this.EditField.Value=0;

                else

                    this.EditField.Enable='off';
                    this.EditField.Tooltip='';
                    this.EditField.Value=0;
                end
            else

                this.EditField.Enable='off';
                this.EditField.Tooltip='';
                this.EditField.Value=0;
            end
        end
    end
end