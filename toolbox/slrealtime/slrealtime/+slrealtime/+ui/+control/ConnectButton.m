classdef ConnectButton<slrealtime.internal.SLRTComponent




    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'ConnectFailed',...
'Disconnected'
        }
    end

    properties(Access=public)
        ConnectedIcon='slrtConnectIcon.png';
        DisconnectedIcon='slrtDisconnectIcon.png';

        ConnectedText=message('slrealtime:appdesigner:Connected').getString();
        DisconnectedText=message('slrealtime:appdesigner:Disconnected').getString();



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

PostConnectedListener
PostDisconnectedListener

        ConnectingText=message('slrealtime:appdesigner:Connecting').getString();
        DisconnectingText=message('slrealtime:appdesigner:Disconnecting').getString();
    end

    methods(Access=protected)
        function setup(this)


            buttonWidth=110;
            buttonHeight=30;



            this.Grid=uigridlayout(this,[1,1],...
            'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
            this.Grid.ColumnWidth={'1x'};
            this.Grid.RowHeight={'1x'};



            this.Button=uibutton(this.Grid,...
            'ButtonPushedFcn',@(o,e)this.buttonPushed());
            this.Button.Layout.Row=1;
            this.Button.Layout.Column=1;
            this.Button.HorizontalAlignment='left';



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
                this.Button.Icon=this.ConnectedIcon;
                this.Button.Text=this.ConnectedText;
                this.Button.Tooltip='';
            else

                this.updateGUI([]);
            end
        end
    end

    methods(Access=private)
        function destroyListeners(this)
            delete(this.PostConnectedListener);
            this.PostConnectedListener=[];
        end

        function createListeners(this)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            this.PostConnectedListener=listener(tg,'PostConnected',...
            @(src,evnt)closeProgressDlg(this));
        end
    end

    methods
        function set.ConnectedIcon(this,value)
            slrealtime.internal.SLRTComponent.validateImageFile('ConnectedIcon',value);
            this.ConnectedIcon=value;
        end

        function set.DisconnectedIcon(this,value)
            slrealtime.internal.SLRTComponent.validateImageFile('DisconnectedIcon',value);
            this.DisconnectedIcon=value;
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)
            this.Button.Enable='off';
            this.Button.Icon=this.DisconnectedIcon;
            this.Button.Text=this.DisconnectedText;


            if(this.isDeployedWithDefaultTarget())
                this.Button.Tooltip=message('slrealtime:appdesigner:DeployedEmptyTargetTooltip').getString();
            else
                this.Button.Tooltip=message('slrealtime:appdesigner:InvalidTargetTooltip',...
                this.GetTargetNameFcnH()).getString();
            end
        end

        function updateGUI(this,~)
            tg=this.tgGetTargetObject();
            if isempty(tg)||this.isDeployedWithDefaultTarget(),return;end



            this.Button.Enable='on';
            if tg.isConnected()
                this.Button.Icon=this.ConnectedIcon;
                this.Button.Text=this.ConnectedText;
                this.Button.Tooltip=message('slrealtime:appdesigner:DisconnectFromTarget',...
                this.GetTargetNameFcnH()).getString();
            else
                this.Button.Icon=this.DisconnectedIcon;
                this.Button.Text=this.DisconnectedText;
                this.Button.Tooltip=message('slrealtime:appdesigner:ConnectToTarget',...
                this.GetTargetNameFcnH()).getString();
            end

            notify(this,'GUIUpdated');
        end
    end

    methods(Access={?slrealtime.ui.container.Menu})
        function buttonPushed(this)
            function postDisconnectedCB(this)
                this.closeProgressDlg();
                delete(this.PostDisconnectedListener);
                this.PostDisconnectedListener=[];
            end

            tg=this.tgGetTargetObject();
            if isempty(tg),return;end





            if tg.isConnected()
                msg=this.DisconnectingText;
                title=message('slrealtime:appdesigner:DisconnectingFromTarget',...
                this.GetTargetNameFcnH()).getString();
            else
                msg=this.ConnectingText;
                title=message('slrealtime:appdesigner:ConnectingToTarget',...
                this.GetTargetNameFcnH()).getString();
            end
            this.openProgressDlg(msg,title);



            try
                if tg.isConnected()







                    this.PostDisconnectedListener=listener(tg,'PostDisconnected',...
                    @(src,evnt)postDisconnectedCB(this));

                    tg.disconnect();
                else
                    tg.connect();
                end
            catch ME
                this.closeProgressDlg();
                this.uialert(ME);
                return;
            end
        end
    end
end
