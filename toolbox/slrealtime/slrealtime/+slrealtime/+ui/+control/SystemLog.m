classdef SystemLog<slrealtime.internal.SLRTComponent

    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
'Disconnected'...
        }
    end

    methods(Access=public)
        function delete(this)
            this.destroySysLogAndListener();
            delete(this.TextAreaContextMenu);
            delete(this.DummyFigure);
        end
    end

    properties(Access=public)
        IncludeTimeStamps=false;



FontName
FontSize
FontWeight
FontAngle
FontColor
    end

    properties(Access={?slrealtime.internal.SLRTComponent},Transient,NonCopyable)
        TextArea matlab.ui.control.TextArea

        TextAreaContextMenu matlab.ui.container.ContextMenu
        IncludeTimeStampsMenu matlab.ui.container.Menu
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

SysLog
SysLogListener

DummyFigure
    end

    methods(Access=private)
        function includeTimeStampsCB(this,o)
            if strcmp(o.Checked,'off')
                this.IncludeTimeStamps=true;
                o.Checked='on';
            else
                this.IncludeTimeStamps=false;
                o.Checked='off';
            end
        end

        function destroySysLogAndListener(this)
            delete(this.SysLog);
            this.SysLog=[];

            delete(this.SysLogListener);
            this.SysLogListener=[];
        end

        function createSysLogAndListener(this)
            if~this.isSimulinkNormalMode()
                tg=this.tgGetTargetObject();
                if isempty(tg),return;end

                this.SysLog=slrealtime.SystemLog(tg);
                this.SysLogListener=listener(tg.get('tc'),'SystemLog',...
                'PostSet',@(src,evnt)this.updateGUIWrapper(evnt));
            end
        end
    end

    methods(Access=protected)
        function setup(this)


            textWidth=450;
            textHeight=200;



            this.Grid=uigridlayout(this,[1,1],...
            'ColumnSpacing',0,'RowSpacing',0,'Padding',0);
            this.Grid.ColumnWidth={'1x'};
            this.Grid.RowHeight={'1x'};



            this.TextArea=uitextarea(this.Grid);
            this.TextArea.Layout.Row=1;
            this.TextArea.Layout.Column=1;
            this.TextArea.HorizontalAlignment='left';
            this.TextArea.Editable='off';



            this.DummyFigure=uifigure;
            this.DummyFigure.Visible='off';
            this.TextAreaContextMenu=uicontextmenu(this.DummyFigure);



            this.IncludeTimeStampsMenu=uimenu(this.TextAreaContextMenu,...
            'MenuSelectedFcn',@(o,e)this.includeTimeStampsCB(o));
            this.IncludeTimeStampsMenu.Checked=this.IncludeTimeStamps;
            this.IncludeTimeStampsMenu.Text=message('slrealtime:appdesigner:SystemLogIncTimeStamps').getString();



            this.Position=[100,100,textWidth,textHeight];
            this.FontName=this.TextArea.FontName;
            this.FontSize=this.TextArea.FontSize;
            this.FontWeight=this.TextArea.FontWeight;
            this.FontAngle=this.TextArea.FontAngle;
            this.FontColor=this.TextArea.FontColor;
            this.BackgroundColor=this.TextArea.BackgroundColor;







            this.Interruptible=false;



            this.tgListenerCreate=@this.createSysLogAndListener;
            this.tgListenerDestroy=@this.destroySysLogAndListener;
        end

        function update(this)
            if this.firstUpdate
                this.firstUpdate=false;



                if isempty(this.GetTargetNameFcnH)
                    this.initTarget([]);
                end
            end

            this.TextArea.FontName=this.FontName;
            this.TextArea.FontSize=this.FontSize;
            this.TextArea.FontWeight=this.FontWeight;
            this.TextArea.FontAngle=this.FontAngle;
            this.TextArea.FontColor=this.FontColor;
            this.TextArea.BackgroundColor=this.BackgroundColor;

            this.IncludeTimeStampsMenu.Checked=this.IncludeTimeStamps;

            if this.isDesignTime()

                this.TextArea.Enable='on';
                this.TextArea.Tooltip='';
                this.TextArea.Value='';
            else

                this.TextAreaContextMenu.Parent=ancestor(this.Parent,'figure');
                this.TextArea.ContextMenu=this.TextAreaContextMenu;

                this.updateGUIWrapper([]);
            end
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)
            this.TextArea.Enable='off';
            this.TextArea.Value='';
            set(this.TextAreaContextMenu.Children,'Visible','off');
            this.TextArea.Tooltip=message('slrealtime:appdesigner:InvalidTargetTooltip',...
            this.GetTargetNameFcnH()).getString();
        end

        function updateGUI(this,evnt)
            if this.isSimulinkNormalMode()
                this.TextArea.Enable='off';
                this.TextArea.Tooltip='';
                this.TextArea.Value='';
                set(this.TextAreaContextMenu.Children,'Visible','off');
            else
                tg=this.tgGetTargetObject();
                if isempty(tg),return;end

                if~tg.isConnected()
                    this.TextArea.Enable='off';
                    this.TextArea.Tooltip='';
                    this.TextArea.Value='';
                    return;
                end

                this.TextArea.Enable='on';
                this.TextArea.Tooltip=message('slrealtime:appdesigner:SystemLogTooltip',this.GetTargetNameFcnH()).getString();
                set(this.TextAreaContextMenu.Children,'Visible','on');

                if isempty(this.SysLog)
                    return;
                end

                if~isempty(evnt)&&isa(evnt,'event.PropertyEvent')
                    this.SysLog.append(evnt.AffectedObject.SystemLog.Message);
                end

                if isempty(this.SysLog.messages)
                    return;
                end

                if this.IncludeTimeStamps
                    dates=this.SysLog.messages{:,1};
                    dates.Format='uuuu-MM-dd'' ''HH:mm:ss';
                    timeStrs=string(dates);
                    this.TextArea.Value=strcat(timeStrs,repmat(" ",length(timeStrs),1),this.SysLog.messages{:,2});
                else
                    this.TextArea.Value=this.SysLog.messages{:,2};
                end
                this.TextArea.scroll('bottom');
            end
        end
    end
end
