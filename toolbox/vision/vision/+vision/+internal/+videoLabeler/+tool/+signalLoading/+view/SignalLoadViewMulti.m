

classdef SignalLoadViewMulti<vision.internal.videoLabeler.tool.signalLoading.view.SignalLoadView


    properties(Access=protected)
SignalViewDisplay

SignalViewPanel

SignalViewPanelPos
    end

    properties(Access=protected)


        ViewPanelHeight=325;

    end




    methods

        function this=SignalLoadViewMulti()
        end

        function open(this,signalInfo,~)

            createDialog(this);

            import vision.internal.videoLabeler.tool.signalLoading.view.*

            this.SignalLoadDisplay=MultiSignalLoadDisplay(this.SignalLoadPanel);
            this.SignalViewDisplay=SignalViewDisplay(this.SignalViewPanel,...
            signalInfo);

            configureListeners(this);

        end

        function configureListeners(this)
            configureListeners@vision.internal.videoLabeler.tool.signalLoading.view.SignalLoadView(this);

            addlistener(this.SignalViewDisplay,'DeleteSignal',...
            @this.deleteSignalCallback);
            addlistener(this.SignalViewDisplay,'ModifySignal',...
            @this.modifySignalCallback);
        end

        function updateOnSignalAdd(this,signalInfoTable)
            if~isempty(this.LoadingDialogFigure)
                updateOnSignalAdd(this.SignalViewDisplay,signalInfoTable);
                resetSignalSource(this);

                this.OKButton.Enable='on';
            end
        end

        function updateOnSignalDelete(this,deleteIndices)
            if~isempty(this.LoadingDialogFigure)

                updateOnSignalDelete(this.SignalViewDisplay,deleteIndices);

                this.OKButton.Enable='on';
            end
        end

        function selection=handleAlerts(this,condition,msg,title)

            import vision.internal.videoLabeler.tool.signalLoading.helpers.*

            selection=handleAlerts(this.LoadingDialogFigure,condition,msg,title);
        end
    end





    methods(Access=protected)

        function createDialog(this)

            createDialog@vision.internal.videoLabeler.tool.signalLoading.view.SignalLoadView(this);

            this.SignalViewPanel=uipanel('Parent',this.LoadingDialogFigure,...
            'Units','pixels',...
            'Position',this.SignalViewPanelPos,...
            'BorderType','none',...
            'Tag','loadDlgViewPanel');
        end

        function calculatePositions(this)

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

            viewPanelY=this.OKCancelButtonY+this.OKCancelButtonHeight+...
            this.HeightPadding;
            this.SignalViewPanelPos=[this.LeftPadding,viewPanelY...
            ,(this.LoadingFigurePos(3)-this.LeftPadding-this.RightPadding)...
            ,this.ViewPanelHeight];

            loadPanelY=viewPanelY+this.ViewPanelHeight+this.HeightPadding;
            this.SignalLoadPanelPos=[this.LeftPadding,loadPanelY...
            ,(this.LoadingFigurePos(3)-this.LeftPadding-this.RightPadding)...
            ,this.LoadPanelHeight];

        end
    end




    methods(Access=protected)

        function onOK(this,~,~)
            isPending=checkPendingChanges(this.SignalLoadDisplay);

            if isPending

                msg=vision.getMessage...
                ('vision:labeler:LoadingDlgSourcePendingWarning');
                title=vision.getMessage('vision:labeler:LoadingDlgWarningTitle');
                yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

                selection=vision.internal.labeler.handleAlert(this.LoadingDialogFigure,'question',...
                msg,title,yes,no,yes);

                if strcmpi(selection,no)
                    return;
                end
            end

            notify(this,'ConfirmChanges');

            this.CheckOnClose=false;
            close(this);
        end

        function onCancel(this,~,~)
            close(this);
        end

        function closeReqCallback(this,~,~)

            isPending=checkPendingChanges(this.SignalLoadDisplay);

            if this.CheckOnClose
                if strcmpi(this.OKButton.Enable,'on')||isPending

                    msg=vision.getMessage...
                    ('vision:labeler:LoadingDlgLoseChangesWarning');
                    title=vision.getMessage('vision:labeler:LoadingDlgWarningTitle');
                    yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                    no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

                    selection=vision.internal.labeler.handleAlert(this.LoadingDialogFigure,...
                    'question',msg,title,yes,no,yes);

                    if strcmpi(selection,no)
                        return;
                    end
                end
            end

            notify(this,'RemoveChanges');

            delete(this.LoadingDialogFigure);
        end
    end

end