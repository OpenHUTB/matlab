
classdef MultiSignalLoadDisplay<vision.internal.videoLabeler.tool.signalLoading.view.SignalLoadDisplay

    properties(Access=private)


AddSourceButton
    end

    properties(Access=private)

        AddButtonY=5;
        AddButtonHeight=25;
        AddButtonWidth=100;
    end

    properties(Access=private)
AddSourceButtonPos
    end

    properties(Access=protected)


        PackageRoot="vision.labeler.loading"
    end




    methods

        function this=MultiSignalLoadDisplay(parent)
            this=this@vision.internal.videoLabeler.tool.signalLoading.view.SignalLoadDisplay(parent);

            addSignalAddButton(this);
        end

    end




    methods(Access=private)

        function addSignalAddButton(this)

            if isa(getCanvas(this.Parent),'matlab.graphics.primitive.canvas.HTMLCanvas')

                this.AddSourceButton=uibutton('Parent',this.Parent,...
                'Text',vision.getMessage('vision:labeler:AddSourceButton'),...
                'Position',this.AddSourceButtonPos,...
                'ButtonPushedFcn',@this.signalAddButtonCallback,...
                'Tag','loadDlgAddSourceBtn');
            else
                this.AddSourceButton=uicontrol('Parent',this.Parent,...
                'Style','pushbutton',...
                'String',vision.getMessage('vision:labeler:AddSourceButton'),...
                'Position',this.AddSourceButtonPos,...
                'Callback',@this.signalAddButtonCallback,...
                'Tag','loadDlgAddSourceBtn');
            end
        end
    end




    methods(Access=protected)
        function calculatePositions(this)

            parentPos=this.Parent.Position;
            parentWidth=parentPos(3);

            this.AddSourceButtonPos=[this.LeftPadding,this.AddButtonY...
            ,this.AddButtonWidth,this.AddButtonHeight];

            signalLoadPanelY=this.AddButtonY+this.AddButtonHeight+this.HeightPadding;
            loadPanelWidth=parentWidth-(this.LeftPadding+this.RightPadding);

            this.SignalLoadPanelPos=[this.LeftPadding,signalLoadPanelY...
            ,loadPanelWidth,this.LoadPanelHeight];

            textPopupY=signalLoadPanelY+this.LoadPanelHeight+this.HeightPadding;
            this.SignalSourceTextPos=[this.LeftPadding,textPopupY...
            ,this.TextWidth,this.TextPopupHeight];

            popupX=this.SignalSourceTextPos(3)+this.WidthPadding;
            this.SignalSourcePopupPos=[popupX,textPopupY,this.PopupWidth...
            ,this.TextPopupHeight];
        end
    end




    methods(Hidden)
        function isPending=checkPendingChanges(this)
            if isa(getCanvas(this.Parent),'matlab.graphics.primitive.canvas.HTMLCanvas')
                value=this.SignalSourcePopup.Value;
            else
                selectedItem=this.SignalSourcePopup.Value;
                value=this.SignalSourcePopup.String{selectedItem};
            end

            loaderId=find(value==[this.SignalSourceList.Name],1);
            signalSourceObj=this.SignalSourceList(loaderId);

            isPending=signalSourceObj.checkPendingChanges();
        end
    end

    methods(Access=protected)
        function defaultSourceIdx=defaultSignalSource(this)



            defaultSourceIdx=([this.SignalSourceList.Name]==string(vision.getMessage('vision:labeler:VideoDisplayName')));
        end
    end

end