function createTreePanel(this)







    options.Tag=this.ApplicationTreePanel_tag;
    options.Title=this.ApplicationTree_msg;
    options.Region="left";
    options.Resizable=true;
    options.Maximizable=false;
    options.PermissibleRegions="left";
    panel=matlab.ui.internal.FigurePanel(options);
    this.App.add(panel);
    grid=uigridlayout(panel.Figure);
    grid.RowHeight={20,12,'1x',25,50,25,'1x'};
    grid.ColumnWidth={20,'1x',20,25};
    grid.RowSpacing=5;
    grid.ColumnSpacing=5;



    function searchTreeCB(this)
        try
            this.refreshTree();
        catch ME
            this.errorDlg('slrealtime:appdesigner:SearchTreeError',ME.message);
            this.SearchEditField.Value='';
        end
    end
    this.SearchImage=uiimage(grid);
    this.SearchImage.Layout.Row=1;
    this.SearchImage.Layout.Column=1;
    this.SearchImage.Enable='off';
    this.SearchImage.ImageSource=this.Search_icon16;
    this.SearchEditField=uieditfield(grid,'text');
    this.SearchEditField.Layout.Row=1;
    this.SearchEditField.Layout.Column=[2,3];
    this.SearchEditField.Enable='off';
    this.SearchEditField.ValueChangedFcn=@(o,e)searchTreeCB(this);




































    function treeConfigureImageClicked(this,grid)
        if strcmp(this.TreeConfigureImage.ImageSource,this.RightArrow_icon12)
            this.TreeConfigureImage.ImageSource=this.DownArrow_icon12;
            grid.RowHeight={20,12,50,'1x',25,50,25,'1x'};
            this.Tree.Layout.Row=[4,8];
            this.AddButton.Layout.Row=5;
            this.EditButton.Layout.Row=7;
            this.TreeConfigurePanel.Parent=grid;
            this.TreeConfigurePanel.Layout.Row=3;
            this.TreeConfigurePanel.Layout.Column=[1,3];
        else
            this.TreeConfigureImage.ImageSource=this.RightArrow_icon12;
            grid.RowHeight={20,12,'1x',25,50,25,'1x'};
            this.Tree.Layout.Row=[3,7];
            this.AddButton.Layout.Row=4;
            this.EditButton.Layout.Row=6;
            this.TreeConfigurePanel.Parent=[];
        end
    end
    this.TreeConfigureImage=uiimage(grid);
    this.TreeConfigureImage.Layout.Row=2;
    this.TreeConfigureImage.Layout.Column=1;
    this.TreeConfigureImage.Enable='off';
    this.TreeConfigureImage.ImageSource=this.RightArrow_icon12;
    this.TreeConfigureImage.ImageClickedFcn=@(o,e)treeConfigureImageClicked(this,grid);
    this.TreeConfigureLabel=uilabel(grid);
    this.TreeConfigureLabel.Layout.Row=2;
    this.TreeConfigureLabel.Layout.Column=[2,3];
    this.TreeConfigureLabel.Enable='off';
    this.TreeConfigureLabel.FontSize=10;
    this.TreeConfigureLabel.Text=this.Options_msg;
    this.TreeConfigureLabel.Tooltip=this.Options_msg;
    this.TreeConfigurePanel=uipanel(grid);
    this.TreeConfigurePanel.Parent=[];
    this.TreeConfigurePanel.BorderType='none';
    configureGrid=uigridlayout(this.TreeConfigurePanel);
    configureGrid.RowHeight={'1x','1x'};
    configureGrid.ColumnWidth={'1x','1x'};
    configureGrid.Padding=[20,0,0,0];
    configureGrid.ColumnSpacing=0;
    configureGrid.RowSpacing=2;



    function treeConfigureSignalsOrParametersChanged(this,e)
        this.markAsDirty();
        try
            this.refreshTree()
        catch ME
            this.errorDlg('slrealtime:appdesigner:UpdateTreeError',ME.message);
            e.Source.Value=e.PreviousValue;
        end
    end
    function refreshTreeOnly(this)
        this.SearchEditField.Value='';
        try
            this.refreshTree()
        catch ME
            this.errorDlg('slrealtime:appdesigner:RefreshTreeError',ME.message);
        end
    end
    this.TreeConfigureSignals=uicheckbox(configureGrid);
    this.TreeConfigureSignals.Text=this.Signals_msg;
    this.TreeConfigureSignals.Value=true;
    this.TreeConfigureSignals.Layout.Row=1;
    this.TreeConfigureSignals.Layout.Column=1;
    this.TreeConfigureSignals.ValueChangedFcn=@(o,e)treeConfigureSignalsOrParametersChanged(this,e);
    this.TreeConfigureParameters=uicheckbox(configureGrid);
    this.TreeConfigureParameters.Text=this.Parameters_msg;
    this.TreeConfigureParameters.Value=true;
    this.TreeConfigureParameters.Layout.Row=1;
    this.TreeConfigureParameters.Layout.Column=2;
    this.TreeConfigureParameters.ValueChangedFcn=@(o,e)treeConfigureSignalsOrParametersChanged(this,e);
    this.TreeConfigureRefreshButton=uibutton(configureGrid);
    this.TreeConfigureRefreshButton.Text=this.Refresh_msg;
    this.TreeConfigureRefreshButton.Icon=this.Refresh_icon16;
    this.TreeConfigureRefreshButton.Layout.Row=2;
    this.TreeConfigureRefreshButton.Layout.Column=1;
    this.TreeConfigureRefreshButton.ButtonPushedFcn=@(o,e)refreshTreeOnly(this);



    this.Tree=uitree(grid);
    this.Tree.Multiselect='on';
    this.Tree.Layout.Row=[3,7];
    this.Tree.Layout.Column=[1,3];
    this.Tree.Enable='off';
    this.Tree.SelectionChangedFcn=@(o,e)this.treeSelectionChanged();



    function addButtonPushed(this)
        for i=1:numel(this.Tree.SelectedNodes)
            node=this.Tree.SelectedNodes(i);
            if isempty(node)||isempty(node.NodeData)||...
                isfield(node.NodeData,'path')
                continue;
            end

            if isfield(node.NodeData,'BlockParameterName')
                this.addParameter(...
                node.Text,...
                node.NodeData.BlockPath,...
                node.NodeData.BlockParameterName);
            else
                this.addSignal(...
                node.Text,...
                node.NodeData.BlockPath,...
                node.NodeData.PortIndex,...
                node.NodeData.SignalLabel);
            end
        end
    end
    this.AddButton=uibutton(grid);
    this.AddButton.Layout.Row=4;
    this.AddButton.Layout.Column=4;
    this.AddButton.Text='';
    this.AddButton.Icon=this.AddRow_icon16;
    this.AddButton.Enable='off';
    this.AddButton.ButtonPushedFcn=@(o,e)addButtonPushed(this);



    function editButtonPushed(this)
        this.BindingData{this.BindingTable.Selection}.BlockPath=this.Tree.SelectedNodes.NodeData.BlockPath;
        this.BindingTable.Data{this.BindingTable.Selection,this.BindingTableAppDataColIdx}=this.Tree.SelectedNodes.Text;
        if this.isTableSelectionParameter()
            this.BindingData{this.BindingTable.Selection}.ParamName=this.Tree.SelectedNodes.NodeData.BlockParameterName;
            this.updateParameterPropertyPanels(this.BindingTable.Selection);
        else
            this.BindingData{this.BindingTable.Selection}.PortIndex=this.Tree.SelectedNodes.NodeData.PortIndex;
            this.BindingData{this.BindingTable.Selection}.SignalName=this.Tree.SelectedNodes.NodeData.SignalLabel;
            this.updateSignalPropertyPanels(this.BindingTable.Selection);
        end
    end
    this.EditButton=uibutton(grid);
    this.EditButton.Layout.Row=6;
    this.EditButton.Layout.Column=4;
    this.EditButton.Text='';
    this.EditButton.Icon=this.EditBindingSource_icon16;
    this.EditButton.Enable='off';
    this.EditButton.ButtonPushedFcn=@(o,e)editButtonPushed(this);
end
