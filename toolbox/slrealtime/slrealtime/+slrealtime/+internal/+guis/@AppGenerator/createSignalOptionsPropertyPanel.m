function createSignalOptionsPropertyPanel(this)








    options.Tag=this.SignalOptionPropsFigPanel_tag;
    options.Title=this.Options_msg;
    options.Region="right";
    options.Resizable=true;
    options.Maximizable=false;
    options.Contextual=true;
    options.PermissibleRegions="right";
    panel=matlab.ui.internal.FigurePanel(options);
    this.App.add(panel);
    grid=uigridlayout(panel.Figure);
    grid.ColumnWidth={'2x','3x',50};
    grid.RowHeight={25,25,25,25};
    grid.ColumnSpacing=3;
    grid.RowSpacing=3;
    grid.Padding=[5,5,5,5];



    function busElementChanged(this,e)
        this.BindingData{this.BindingTable.Selection}.BusElement=e.Value;
    end
    label=uilabel(grid);
    label.Layout.Row=1;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.BusElement_msg;
    label.Tooltip={this.BusElementSignalPropTooltip_msg};
    this.SignalBusElementEditField=uieditfield(grid,'text');
    this.SignalBusElementEditField.Layout.Row=1;
    this.SignalBusElementEditField.Layout.Column=[2,3];
    this.SignalBusElementEditField.ValueChangedFcn=@(o,e)busElementChanged(this,e);



    function arrayIndexChanged(this,e)
        prevArrayIndex=e.PreviousValue;

        function revert()
            this.SignalArrayIndexEditField.Value=prevArrayIndex;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedSignal=this.BindingTable.Selection;
        newArrayIndex=e.Value;



        if~isempty(newArrayIndex)
            valid=false;
            try
                [temp,ok]=str2num(newArrayIndex);
                if ok&&all(isreal(temp))&&all(arrayfun(@(x)floor(x)==x,temp))
                    valid=true;
                end
            catch
                valid=false;
            end
            if~valid
                throwError(this.InvalidArrayIndex_msg);
                return;
            end
        end



        this.BindingData{selectedSignal}.ArrayIndex=newArrayIndex;
    end
    label=uilabel(grid);
    label.Layout.Row=2;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.ArrayIndex_msg;
    label.Tooltip={this.ArrayIndexSignalPropTooltip_msg};
    this.SignalArrayIndexEditField=uieditfield(grid,'text');
    this.SignalArrayIndexEditField.Layout.Row=2;
    this.SignalArrayIndexEditField.Layout.Column=[2,3];
    this.SignalArrayIndexEditField.ValueChangedFcn=@(o,e)arrayIndexChanged(this,e);



    function decimationChanged(this,e)
        prevDecimation=e.PreviousValue;

        function revert()
            this.SignalDecimationEditField.Value=prevDecimation;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedSignal=this.BindingTable.Selection;
        newDecimation=e.Value;



        if~isempty(newDecimation)
            valid=false;
            try
                temp=str2double(newDecimation);
                if~isnan(temp)&&isreal(temp)&&isscalar(temp)&&(floor(temp)==temp)
                    valid=true;
                end
            catch
                valid=false;
            end
            if~valid
                throwError(this.InvalidDecimation_msg);
                return;
            end
        end



        this.BindingData{selectedSignal}.Decimation=newDecimation;
    end
    label=uilabel(grid);
    label.Layout.Row=3;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.Decimation_msg;
    label.Tooltip={this.DecimationSignalPropTooltip_msg};
    this.SignalDecimationEditField=uieditfield(grid,'text');
    this.SignalDecimationEditField.Layout.Row=3;
    this.SignalDecimationEditField.Layout.Column=[2,3];
    this.SignalDecimationEditField.ValueChangedFcn=@(o,e)decimationChanged(this,e);



    function callbackChanged(this,e)
        prevCallback=e.PreviousValue;

        function revert()
            this.SignalCallbackEditField.Value=prevCallback;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedSignal=this.BindingTable.Selection;
        newCallback=e.Value;



        if~isempty(newCallback)
            valid=true;
            try
                temp=eval(newCallback);
                if~isa(temp,'function_handle')
                    valid=false;
                end
            catch
                valid=false;
            end
            if~valid
                throwError(this.InvalidCallback_msg);
                return;
            end
        end



        this.BindingData{selectedSignal}.Callback=newCallback;
    end
    label=uilabel(grid);
    label.Layout.Row=4;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.Callback_msg;
    label.Tooltip={this.CallbackSignalPropTooltip_msg};
    this.SignalCallbackEditField=uieditfield(grid,'text');
    this.SignalCallbackEditField.Layout.Row=4;
    this.SignalCallbackEditField.Layout.Column=[2,3];
    this.SignalCallbackEditField.ValueChangedFcn=@(o,e)callbackChanged(this,e);
end