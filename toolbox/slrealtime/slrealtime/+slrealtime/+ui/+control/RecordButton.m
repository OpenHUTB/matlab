classdef RecordButton<slrealtime.internal.SLRTComponent




    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'RecordingStarted',...
'RecordingStopped'...
        }
    end

    properties(Access=public)
        StartRecordingIcon='slrtStartRecordingIcon.png';
        StopRecordingIcon='slrtStopRecordingIcon.png';

        StartRecordingText={...
        message('slrealtime:appdesigner:StartRecordingText1').getString()...
        ,message('slrealtime:appdesigner:StartRecordingText2').getString()};
        StopRecordingText={...
        message('slrealtime:appdesigner:StopRecordingText1').getString()...
        ,message('slrealtime:appdesigner:StopRecordingText2').getString()};



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
    end

    properties(Access={?slrealtime.internal.SLRTComponent},Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout
    end

    methods(Access=protected)
        function setup(this)


            buttonWidth=65;
            buttonHeight=65;



            this.Grid=uigridlayout(this,[1,1],...
            'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
            this.Grid.ColumnWidth={'1x'};
            this.Grid.RowHeight={'1x'};



            this.Button=uibutton(this.Grid,...
            'ButtonPushedFcn',@(o,e)this.buttonPushed());
            this.Button.Layout.Row=1;
            this.Button.Layout.Column=1;
            this.Button.HorizontalAlignment='center';
            this.Button.IconAlignment='top';



            this.Position=[100,100,buttonWidth,buttonHeight];
            this.FontName=this.Button.FontName;
            this.FontSize=this.Button.FontSize;
            this.FontWeight=this.Button.FontWeight;
            this.FontAngle=this.Button.FontAngle;
            this.FontColor=this.Button.FontColor;
            this.IconAlignment=this.Button.IconAlignment;
            this.HorizontalAlignment=this.Button.HorizontalAlignment;
            this.VerticalAlignment=this.Button.VerticalAlignment;
            this.BackgroundColor=this.Button.BackgroundColor;
        end

        function update(this)
            if this.firstUpdate
                this.firstUpdate=false;



                if isempty(this.GetTargetNameFcnH)
                    this.initTarget([]);
                end
            end

            this.Button.FontName=this.FontName;
            this.Button.FontSize=this.FontSize;
            this.Button.FontWeight=this.FontWeight;
            this.Button.FontAngle=this.FontAngle;
            this.Button.FontColor=this.FontColor;
            this.Button.IconAlignment=this.IconAlignment;
            this.Button.HorizontalAlignment=this.HorizontalAlignment;
            this.Button.VerticalAlignment=this.VerticalAlignment;
            this.Button.BackgroundColor=this.BackgroundColor;

            if this.isDesignTime()

                this.Button.Enable='on';
                this.Button.Icon=this.StopRecordingIcon;
                this.Button.Text=this.StopRecordingText;
                this.Button.Tooltip='';
            else

                this.updateGUI([]);
            end
        end
    end

    methods
        function set.StartRecordingIcon(this,value)
            slrealtime.internal.SLRTComponent.validateImageFile('StartRecordingIcon',value);
            this.StartRecordingIcon=value;
        end

        function set.StopRecordingIcon(this,value)
            slrealtime.internal.SLRTComponent.validateImageFile('StopRecordingIcon',value);
            this.StopRecordingIcon=value;
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)
            this.Button.Enable='off';
            this.Button.Icon=this.StartRecordingIcon;
            this.Button.Text=this.StopRecordingText;
            this.Button.Tooltip=message('slrealtime:appdesigner:InvalidTargetTooltip',...
            this.GetTargetNameFcnH()).getString();
        end

        function updateGUI(this,~)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            if this.isSimulinkNormalMode()


                this.Button.Enable='off';
                this.Button.Icon=this.StopRecordingIcon;
                this.Button.Text=this.StopRecordingText;
                this.Button.Tooltip='';
            else
                this.Button.Enable='on';

                tg=this.tgGetTargetObject();
                if isempty(tg),return;end

                if tg.get('Recording')
                    this.Button.Icon=this.StopRecordingIcon;
                    this.Button.Text=this.StopRecordingText;
                    this.Button.Tooltip=message('slrealtime:appdesigner:StopRecordingTooltip',...
                    this.GetTargetNameFcnH()).getString();
                else
                    this.Button.Icon=this.StartRecordingIcon;
                    this.Button.Text=this.StartRecordingText;
                    this.Button.Tooltip=message('slrealtime:appdesigner:StartRecordingTooltip',...
                    this.GetTargetNameFcnH()).getString();
                end
            end
        end
    end

    methods(Access={?slrealtime.ui.container.Menu,?slrealtime.internal.SLRTComponent})
        function buttonPushed(this)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            if tg.get('Recording')
                tg.stopRecording();
            else
                tg.startRecording();
            end
        end
    end
end
