function createSignalLinePropertyPanel(this)








    options.Tag=this.SignalLinePropsFigPanel_tag;
    options.Title=this.AxesLine_msg;
    options.Region="right";
    options.Resizable=true;
    options.Maximizable=false;
    options.Contextual=true;
    options.PermissibleRegions="right";
    panel=matlab.ui.internal.FigurePanel(options);
    this.App.add(panel);
    grid=uigridlayout(panel.Figure);
    grid.ColumnWidth={'2x','3x',50};
    grid.RowHeight={25,25,25,25,25};
    grid.ColumnSpacing=3;
    grid.RowSpacing=3;
    grid.Padding=[5,5,5,5];



    function widthChanged(this,e)
        prevLineWidth=e.PreviousValue;

        function revert()
            this.SignalLineWidthEditField.Value=prevLineWidth;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedSignal=this.BindingTable.Selection;
        newLineWidth=e.Value;

        if~isempty(newLineWidth)&&...
            ~slrealtime.instrument.LineStyle.validateWidth(str2double(newLineWidth))
            throwError(this.InvalidLineWidth_msg);
            return;
        end

        this.BindingData{selectedSignal}.LineWidth=newLineWidth;
    end
    label=uilabel(grid);
    label.Layout.Row=1;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.LineWidth_msg;
    label.Tooltip={this.LineWidthSignalPropTooltip_msg};
    this.SignalLineWidthEditField=uieditfield(grid,'text');
    this.SignalLineWidthEditField.Layout.Row=1;
    this.SignalLineWidthEditField.Layout.Column=[2,3];
    this.SignalLineWidthEditField.ValueChangedFcn=@(o,e)widthChanged(this,e);



    function styleChanged(this,e)
        this.BindingData{this.BindingTable.Selection}.LineStyle=e.Value;
    end
    label=uilabel(grid);
    label.Layout.Row=2;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.LineStyle_msg;
    label.Tooltip={this.LineStyleSignalPropTooltip_msg};
    this.SignalLineStyleDropDown=uidropdown(grid);
    this.SignalLineStyleDropDown.Items=[{''},slrealtime.instrument.LineStyle.ValidStyles];
    this.SignalLineStyleDropDown.Value='';
    this.SignalLineStyleDropDown.Layout.Row=2;
    this.SignalLineStyleDropDown.Layout.Column=[2,3];
    this.SignalLineStyleDropDown.ValueChangedFcn=@(o,e)styleChanged(this,e);



    function colorChanged(this,e)
        prevLineColor=e.PreviousValue;

        function revert()
            this.SignalLineColorEditField.Value=prevLineColor;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedSignal=this.BindingTable.Selection;
        newLineColor=e.Value;
        newLineColorNum=str2num(newLineColor);%#ok

        if~isempty(newLineColor)&&...
            ~slrealtime.instrument.LineStyle.validateColor(newLineColorNum)
            throwError(this.InvalidLineColor_msg);
            return;
        end

        if newLineColorNum==slrealtime.instrument.LineStyle.ColorDefault
            this.SignalLineColorPickerButton.BackgroundColor=[1,1,1];
        else
            this.SignalLineColorPickerButton.BackgroundColor=newLineColorNum;
        end

        this.BindingData{selectedSignal}.LineColor=newLineColor;
    end
    function colorPickerDropDownOpenFcn(this)
        autoColor=false;
        currColor=str2num(this.SignalLineColorEditField.Value);%#ok
        if currColor==slrealtime.instrument.LineStyle.ColorDefault

            autoColor=true;
            currColor=[1,1,1];
        end
        color=uisetcolor(currColor);
        this.bringToFront();
        if autoColor&&all(color==currColor)

            color=slrealtime.instrument.LineStyle.ColorDefault;
        end
        this.SignalLineColorEditField.Value=num2str(color);
        e.Value=this.SignalLineColorEditField.Value;
        e.PreviousValue=e.Value;
        this.SignalLineColorEditField.ValueChangedFcn(this,e);
    end
    label=uilabel(grid);
    label.Layout.Row=3;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.LineColor_msg;
    label.Tooltip={this.LineColorSignalPropTooltip_msg};
    this.SignalLineColorEditField=uieditfield(grid,'text');
    this.SignalLineColorEditField.Layout.Row=3;
    this.SignalLineColorEditField.Layout.Column=2;
    this.SignalLineColorEditField.ValueChangedFcn=@(o,e)colorChanged(this,e);
    this.SignalLineColorPickerPanel=uipanel(grid);
    this.SignalLineColorPickerPanel.Layout.Row=3;
    this.SignalLineColorPickerPanel.Layout.Column=3;
    this.SignalLineColorPickerPanel.BorderType='none';
    this.SignalLineColorPickerDropDown=uidropdown(this.SignalLineColorPickerPanel);
    this.SignalLineColorPickerDropDown.Items={};
    this.SignalLineColorPickerDropDown.Position=[1,1,50,25];
    this.SignalLineColorPickerDropDown.Value={};
    this.SignalLineColorPickerDropDown.DropDownOpeningFcn=@(o,e)colorPickerDropDownOpenFcn(this);
    this.SignalLineColorPickerButton=uibutton(this.SignalLineColorPickerPanel);
    this.SignalLineColorPickerButton.Text='';
    this.SignalLineColorPickerButton.Position=[5,3,22,21];
    this.SignalLineColorPickerButton.ButtonPushedFcn=@(o,e)colorPickerDropDownOpenFcn(this);



    function markerChanged(this,e)
        this.BindingData{this.BindingTable.Selection}.LineMarker=e.Value;
    end
    label=uilabel(grid);
    label.Layout.Row=4;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.LineMarker_msg;
    label.Tooltip={this.LineMarkerSignalPropTooltip_msg};
    this.SignalLineMarkerDropDown=uidropdown(grid);
    this.SignalLineMarkerDropDown.Items=slrealtime.instrument.LineStyle.ValidMarkers;
    this.SignalLineMarkerDropDown.Value=slrealtime.instrument.LineStyle.MarkerDefault;
    this.SignalLineMarkerDropDown.Layout.Row=4;
    this.SignalLineMarkerDropDown.Layout.Column=[2,3];
    this.SignalLineMarkerDropDown.ValueChangedFcn=@(o,e)markerChanged(this,e);



    function markerSizeChanged(this,e)
        prevLineMarkerSize=e.PreviousValue;

        function revert()
            this.SignalLineMarkerSizeEditField.Value=prevLineMarkerSize;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedSignal=this.BindingTable.Selection;
        newLineMarkerSize=e.Value;

        if~isempty(newLineMarkerSize)&&...
            ~slrealtime.instrument.LineStyle.validateMarkerSize(str2double(newLineMarkerSize))
            throwError(this.InvalidLineMarkerSize_msg);
            return;
        end

        this.BindingData{selectedSignal}.LineMarkerSize=e.Value;
    end
    label=uilabel(grid);
    label.Layout.Row=5;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.LineMarkerSize_msg;
    label.Tooltip={this.LineMarkerSizeSignalPropTooltip_msg};
    this.SignalLineMarkerSizeEditField=uieditfield(grid,'text');
    this.SignalLineMarkerSizeEditField.Layout.Row=5;
    this.SignalLineMarkerSizeEditField.Layout.Column=[2,3];
    this.SignalLineMarkerSizeEditField.ValueChangedFcn=@(o,e)markerSizeChanged(this,e);
end