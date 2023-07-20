classdef SignalLoadView<handle

    properties(Access=protected)
SignalLoadDisplay

    end

    properties(Access=protected)
LoadingDialogFigure

SignalLoadPanel

OKButton
CancelButton
    end

    properties(Access=protected)
LoadingFigurePos
SignalLoadPanelPos

OKButtonPos
CancelButtonPos

        CheckOnClose=true
    end

    properties(Access=protected)

        LoadingDlgWidth=1000;
        LoadingDlgHeight=600;


        LeftPadding=50;
        RightPadding=50;


        LoadPanelHeight=200;

        OKCancelButtonY=10;
        OKCancelButtonHeight=30;
        OKCancelButtonWidth=50;

        HeightPadding=10;
    end

    events
AddSignalSource
DeleteSignal
ModifySignal

ConfirmChanges
RemoveChanges
    end




    methods

        function this=SignalLoadView()
        end

        function configureListeners(this)
            addlistener(this.SignalLoadDisplay,'AddSignalSource',...
            @this.addSignalSourceCallback);
        end

        function wait(this)
            if~isempty(this.LoadingDialogFigure)
                uiwait(this.LoadingDialogFigure);
            end
        end

        function close(this)
            close(this.LoadingDialogFigure);
        end

        function loadFromSourceObj(this,sources)

            if isa(sources,'groundTruthDataSource')
                import vision.internal.videoLabeler.tool.signalLoading.helpers.*
                sources=createMultiSourceFromGTDataSource(sources);
            end

            for idx=1:numel(sources)

                import vision.internal.videoLabeler.tool.signalLoading.events.*
                evtData=AddSignalSourceEvent(sources(idx));

                notify(this,'AddSignalSource',evtData);
            end

            notify(this,'ConfirmChanges');

        end

        function[source,sourceParams]=openFixSourceView(~,~)
            source=[];
            sourceParams=[];
        end

        function resetSignalSource(this)
            resetSignalSource(this.SignalLoadDisplay);
        end
    end




    methods(Access=protected)

        function createDialog(this)

            calculatePositions(this);

            if~vision.internal.labeler.jtfeature('useAppContainer')
                this.LoadingDialogFigure=figure(...
                'Name',vision.getMessage('vision:labeler:LoadingDialogTitle'),...
                'Position',this.LoadingFigurePos,...
                'IntegerHandle','off',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'WindowStyle','modal',...
                'Visible','on',...
                'CloseRequestFcn',@this.closeReqCallback,...
                'Resize','off',...
                'Tag','loadDlgFigure');

            else

                this.LoadingDialogFigure=uifigure(...
                'Name',vision.getMessage('vision:labeler:LoadingDialogTitle'),...
                'Position',this.LoadingFigurePos,...
                'IntegerHandle','off',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'WindowStyle','modal',...
                'Visible','on',...
                'CloseRequestFcn',@this.closeReqCallback,...
                'Resize','off',...
                'Tag','loadDlgFigure');
            end

            this.SignalLoadPanel=uipanel('Parent',this.LoadingDialogFigure,...
            'Units','pixels',...
            'Position',this.SignalLoadPanelPos,...
            'BorderType','none',...
            'Tag','loadDlgLoadPanel');

            addOKCancelButton(this);
        end

        function addOKCancelButton(this)

            if isa(getCanvas(this.LoadingDialogFigure),'matlab.graphics.primitive.canvas.HTMLCanvas')
                this.OKButton=uibutton('Parent',this.LoadingDialogFigure,...
                'Position',this.OKButtonPos,...
                'Text',vision.getMessage('MATLAB:uistring:popupdialogs:OK'),...
                'Enable','off',...
                'ButtonPushedFcn',@this.onOK,...
                'Tag','loadDlgOKButton');

                this.CancelButton=uibutton('Parent',this.LoadingDialogFigure,...
                'Position',this.CancelButtonPos,...
                'Text',vision.getMessage('MATLAB:uistring:popupdialogs:Cancel'),...
                'Enable','on',...
                'ButtonPushedFcn',@this.onCancel,...
                'Tag','loadDlgCancelButton');
            else
                this.OKButton=uicontrol('Parent',this.LoadingDialogFigure,...
                'Style','pushbutton',...
                'Position',this.OKButtonPos,...
                'String',vision.getMessage('MATLAB:uistring:popupdialogs:OK'),...
                'Enable','off',...
                'Callback',@this.onOK,...
                'Tag','loadDlgOKButton');

                this.CancelButton=uicontrol('Parent',this.LoadingDialogFigure,...
                'Style','pushbutton',...
                'Position',this.CancelButtonPos,...
                'String',vision.getMessage('MATLAB:uistring:popupdialogs:Cancel'),...
                'Enable','on',...
                'Callback',@this.onCancel,...
                'Tag','loadDlgCancelButton');
            end


        end
    end

    methods(Abstract,Access=protected)
        calculatePositions(this)
    end




    methods(Access=protected)
        function addSignalSourceCallback(this,~,evtData)
            notify(this,'AddSignalSource',evtData);
        end

        function deleteSignalCallback(this,~,evtData)
            notify(this,'DeleteSignal',evtData);
        end

        function modifySignalCallback(this,~,evtData)
            notify(this,'ModifySignal',evtData);
        end
    end




    methods(Abstract,Access=protected)
        onOK(this,~,~)

        onCancel(this,~,~)

        closeReqCallback(this,~,~)
    end
end