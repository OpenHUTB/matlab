function createBindingTable(this)







    options.Tag=this.ComponentsDocumentGroup_tag;
    options.Context=matlab.ui.container.internal.appcontainer.ContextDefinition();
    options.Maximizable=false;
    group=matlab.ui.internal.FigureDocumentGroup(options);
    this.App.add(group);

    figOptions.Title=this.Bindings_msg;
    figOptions.Tag=this.BindingsDocument_tag;
    figOptions.DocumentGroupTag=this.ComponentsDocumentGroup_tag;
    figOptions.Closable=false;
    figOptions.Maximizable=false;
    document=matlab.ui.internal.FigureDocument(figOptions);
    document.Figure.AutoResizeChildren='on';
    this.App.add(document);

    bindingGrid=uigridlayout(document.Figure);
    bindingGrid.ColumnWidth={'1x'};
    bindingGrid.RowHeight={'1x'};
    bindingGrid.ColumnSpacing=0;
    bindingGrid.RowSpacing=0;
    bindingGrid.Padding=[0,0,0,0];

    this.BindingTable=uitable(bindingGrid);
    this.BindingTable.ColumnName={'';this.ApplicationData_msg;this.ControlName_msg;this.ControlType_msg};
    this.BindingTable.RowName={};
    this.BindingTable.ColumnSortable=[false,false,false,false];
    this.BindingTable.ColumnEditable=[false,false,false,false];
    this.BindingTable.ColumnWidth={25,'auto','auto','auto'};
    this.BindingTable.RowStriping='off';
    this.BindingTable.SelectionChangedFcn=@(o,e)this.bindingTableCellSelectionCB();
    this.BindingTable.Layout.Row=1;
    this.BindingTable.Layout.Column=1;
    this.BindingTable.Visible='off';
    this.BindingTable.SelectionType='row';
    this.BindingTable.Data={};
end