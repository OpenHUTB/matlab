

classdef LidarLoadView<vision.internal.videoLabeler.tool.signalLoading.view.SignalLoadView






    methods

        function this=LidarLoadView()





        end

        function open(this,signalInfo,view)




            createDialog(this);
            import lidar.internal.lidarLabeler.tool.signalLoading.view.*

            this.SignalLoadDisplay=LidarLoadDisplay(this.SignalLoadPanel);

            configureListeners(this);

            if height(signalInfo)~=0

                deleteIdx=1;

                import vision.internal.videoLabeler.tool.signalLoading.events.*
                evtData=DeleteSignalEvent(deleteIdx);

                notify(this,'DeleteSignal',evtData);
            end
        end

        function updateOnSignalAdd(this,~)
            if~isempty(this.LoadingDialogFigure)
                resetSignalSource(this);

                this.OKButton.Enable='on';
            end
        end

        function updateOnSignalDelete(this,~)
            this.OKButton.Enable='on';
        end
    end





    methods(Access=protected)

        function createDialog(this)

            createDialog@vision.internal.videoLabeler.tool.signalLoading.view.SignalLoadView(this);
            this.LoadingDialogFigure.Name=vision.getMessage('lidar:labeler:LoadingDialogTitle');
            this.OKButton.Enable='on';
        end

        function calculatePositions(this)
            this.LoadingDlgHeight=280;

            screenSize=get(0,'ScreenSize');

            screenWidth=screenSize(3);
            screenHeight=screenSize(4);

            x=(screenWidth-this.LoadingDlgWidth)/2;
            y=(screenHeight-this.LoadingDlgHeight)/2;

            this.LoadingFigurePos=[x,y,this.LoadingDlgWidth,this.LoadingDlgHeight];

            okButtonX=(this.LoadingDlgWidth/2)-(this.OKCancelButtonWidth)-10;
            cancelButtonX=(this.LoadingDlgWidth/2)+10;

            this.OKButtonPos=[okButtonX,this.OKCancelButtonY...
            ,this.OKCancelButtonWidth,this.OKCancelButtonHeight];
            this.CancelButtonPos=[cancelButtonX,this.OKCancelButtonY...
            ,this.OKCancelButtonWidth,this.OKCancelButtonHeight];

            loadPanelY=this.OKCancelButtonY+this.OKCancelButtonHeight+...
            this.HeightPadding;

            this.SignalLoadPanelPos=[this.LeftPadding,loadPanelY...
            ,(this.LoadingFigurePos(3)-this.LeftPadding-this.RightPadding)...
            ,this.LoadPanelHeight];
        end
    end




    methods(Access=protected)

        function onOK(this,~,~)
            isAdded=this.SignalLoadDisplay.addingPointCloudSource();

            if~isAdded
                return;
            end

            notify(this,'ConfirmChanges');

            this.CheckOnClose=false;
            close(this);
        end

        function onCancel(this,~,~)
            this.CheckOnClose=false;
            close(this);
        end

        function closeReqCallback(this,~,~)

            this.CheckOnClose=false;
            notify(this,'RemoveChanges');

            delete(this.LoadingDialogFigure);
        end
    end

end
