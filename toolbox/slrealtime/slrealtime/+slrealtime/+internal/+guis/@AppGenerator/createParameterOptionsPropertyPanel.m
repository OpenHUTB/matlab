function createParameterOptionsPropertyPanel(this)








    options.Tag=this.ParameterOptionPropsFigPanel_tag;
    options.Title=this.Options_msg;
    options.Region="right";
    options.Resizable=true;
    options.Maximizable=false;
    options.Contextual=true;
    options.PermissibleRegions="right";
    panel=matlab.ui.internal.FigurePanel(options);
    this.App.add(panel);
    grid=uigridlayout(panel.Figure);
    grid.ColumnWidth={'2x','3x'};
    grid.RowHeight={25};
    grid.ColumnSpacing=3;
    grid.RowSpacing=3;
    grid.Padding=[5,5,5,5];



    function elementChanged(this,e)
        this.BindingData{this.BindingTable.Selection}.Element=e.Value;
        strs=split(this.BindingTable.Data{this.BindingTable.Selection,this.BindingTableAppDataColIdx},':');
        strs{end}=[this.BindingData{this.BindingTable.Selection}.ParamName,e.Value];
        this.BindingTable.Data(this.BindingTable.Selection,this.BindingTableAppDataColIdx)=join(strs,':');
    end
    label=uilabel(grid);
    label.Layout.Row=1;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.Element_msg;
    label.Tooltip={this.ElementParamPropTooltip_msg};
    this.ParameterElementEditField=uieditfield(grid,'text');
    this.ParameterElementEditField.Layout.Row=1;
    this.ParameterElementEditField.Layout.Column=2;
    this.ParameterElementEditField.ValueChangedFcn=@(o,e)elementChanged(this,e);
end