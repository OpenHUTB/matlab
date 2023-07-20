function createSignalPropertyPanel(this)








    options.Tag=this.SignalPropsFigPanel_tag;
    options.Title=this.Signal_msg;
    options.Region="right";
    options.Resizable=true;
    options.Maximizable=false;
    options.Collapsible=false;
    options.Contextual=true;
    options.PermissibleRegions="right";
    panel=matlab.ui.internal.FigurePanel(options);
    this.App.add(panel);
    grid=uigridlayout(panel.Figure);
    grid.ColumnWidth={'2x','3x',50};
    grid.RowHeight={25,25,25};
    grid.ColumnSpacing=3;
    grid.RowSpacing=3;
    grid.Padding=[5,5,5,5];



    label=uilabel(grid);
    label.Layout.Row=1;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.BlockPath_msg;
    label.Tooltip={this.BlockPathSignalPropTooltip_msg};
    this.SignalBlockPathEditField=uieditfield(grid,'text');
    this.SignalBlockPathEditField.Editable=false;
    this.SignalBlockPathEditField.Layout.Row=1;
    this.SignalBlockPathEditField.Layout.Column=[2,3];



    label=uilabel(grid);
    label.Layout.Row=2;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.PortIndex_msg;
    label.Tooltip={this.PortIndexSignalPropTooltip_msg};
    this.SignalPortIndexEditField=uieditfield(grid,'text');
    this.SignalPortIndexEditField.Editable=false;
    this.SignalPortIndexEditField.Layout.Row=2;
    this.SignalPortIndexEditField.Layout.Column=[2,3];



    label=uilabel(grid);
    label.Layout.Row=3;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.SignalName_msg;
    label.Tooltip={this.SignalNameSignalPropTooltip_msg};
    this.SignalNameEditField=uieditfield(grid,'text');
    this.SignalNameEditField.Editable=false;
    this.SignalNameEditField.Layout.Row=3;
    this.SignalNameEditField.Layout.Column=[2,3];
end
