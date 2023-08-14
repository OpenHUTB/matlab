function createParameterPropertyPanel(this)








    options.Tag=this.ParameterPropsFigPanel_tag;
    options.Title=this.Parameter_msg;
    options.Region="right";
    options.Resizable=true;
    options.Maximizable=false;
    options.Collapsible=false;
    options.Contextual=true;
    options.PermissibleRegions="right";
    panel=matlab.ui.internal.FigurePanel(options);
    this.App.add(panel);
    grid=uigridlayout(panel.Figure);
    grid.ColumnWidth={'2x','3x'};
    grid.RowHeight={25,25};
    grid.ColumnSpacing=3;
    grid.RowSpacing=3;
    grid.Padding=[5,5,5,5];



    label=uilabel(grid);
    label.Layout.Row=1;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.BlockPath_msg;
    label.Tooltip={this.BlockPathParamPropTooltip_msg};
    this.ParameterBlockPathEditField=uieditfield(grid,'text');
    this.ParameterBlockPathEditField.Editable=false;
    this.ParameterBlockPathEditField.Layout.Row=1;
    this.ParameterBlockPathEditField.Layout.Column=2;



    label=uilabel(grid);
    label.Layout.Row=2;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.ParameterName_msg;
    label.Tooltip={this.ParameterNameParamPropTooltip_msg};
    this.ParameterNameEditField=uieditfield(grid,'text');
    this.ParameterNameEditField.Editable=false;
    this.ParameterNameEditField.Layout.Row=2;
    this.ParameterNameEditField.Layout.Column=2;
end