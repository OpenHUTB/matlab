classdef RebootButton<slrealtime.internal.SLRTComponent




    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        }
    end

    properties(Access=public)
        RebootIcon='slrtRebootIcon.png';
        RebootText=message('slrealtime:appdesigner:RebootText').getString();
        WaitForReboot=true;



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
                this.Button.Icon=this.RebootIcon;
                this.Button.Text=this.RebootText;
                this.Button.Tooltip='';
            else

                this.updateGUI([]);
            end
        end
    end

    methods
        function set.RebootIcon(this,value)
            slrealtime.internal.SLRTComponent.validateImageFile('RebootIcon',value);
            this.RebootIcon=value;
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)
            this.Button.Enable='off';
            this.Button.Icon=this.RebootIcon;
            this.Button.Text=this.RebootText;
            this.Button.Tooltip=message('slrealtime:appdesigner:InvalidTargetTooltip',...
            this.GetTargetNameFcnH()).getString();
        end

        function updateGUI(this,~)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            if this.isSimulinkNormalMode()


                this.Button.Enable='off';
                this.Button.Icon=this.RebootIcon;
                this.Button.Text=this.RebootText;
                this.Button.Tooltip='';
            else
                this.Button.Enable='on';
                this.Button.Icon=this.RebootIcon;
                this.Button.Text=this.RebootText;
                this.Button.Tooltip=message('slrealtime:appdesigner:RebootTooltip',...
                this.GetTargetNameFcnH()).getString();
            end
        end
    end

    methods(Access=private)
        function closeConfirmCB(this,tg,e)
            if e.SelectedOptionIndex==1
                msg=message('slrealtime:appdesigner:Rebooting',this.GetTargetNameFcnH());
                title=message('slrealtime:appdesigner:RebootTitle');
                this.openProgressDlg(msg.getString(),title.getString());

                try
                    tg.reboot();

                    if(this.WaitForReboot)
                        startTime=tic;
                        pause(1);
                        timeoutVal=240;
                        timeout=true;
                        while toc(startTime)<timeoutVal
                            if ispc
                                cmd=['ping -n 1 ',tg.TargetSettings.address];
                            else
                                cmd=['ping -c 1 ',tg.TargetSettings.address];
                            end
                            [status,result]=system(cmd);
                            if~status&&contains(result,'TTL','IgnoreCase',true)
                                timeout=false;
                                break;
                            end
                            pause(2);
                        end
                        this.closeProgressDlg();

                        if timeout
                            msg=message('slrealtime:appdesigner:RebootTimeout',this.GetTargetNameFcnH());
                            title=message('slrealtime:appdesigner:RebootTitle');
                            uialert(...
                            ancestor(this.Parent,'figure'),...
                            msg.getString(),title.getString());
                            return;
                        end

                        msg=message('slrealtime:appdesigner:RebootCompleted',this.GetTargetNameFcnH());
                        title=message('slrealtime:appdesigner:RebootTitle');
                        uiconfirm(ancestor(this.Parent,'figure'),...
                        msg.getString(),title.getString(),'Icon','success',...
                        'Options',{getString(message('MATLAB:uitools:uidialogs:OK'))});
                    else
                        this.closeProgressDlg();
                    end

                catch ME
                    this.closeProgressDlg();
                    this.uialert(ME);
                    return;
                end
            else

            end
        end
    end

    methods(Access={?slrealtime.ui.container.Menu,?slrealtime.internal.SLRTComponent})
        function buttonPushed(this)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            confirmMsg=message('slrealtime:appdesigner:RebootConfirm',this.GetTargetNameFcnH());
            confirmTitle=message('slrealtime:appdesigner:RebootTitle');
            uiconfirm(...
            ancestor(this.Parent,'figure'),...
            confirmMsg.getString(),...
            confirmTitle.getString(),...
            'CloseFcn',@(o,e)closeConfirmCB(this,tg,e));
        end
    end
end
