function updateEditButtonEnable(this)





    if isempty(this.Tree.SelectedNodes)
        this.EditButton.Enable='off';
    else





        if~isempty(this.BindingTable.Selection)&&...
            numel(this.BindingTable.Selection)==1&&...
            numel(this.Tree.SelectedNodes)==1&&...
            ((this.isTableSelectionParameter()&&slrealtime.internal.ApplicationTree.isTreeNodeParameter(this.Tree.SelectedNodes))||...
            (~this.isTableSelectionParameter()&&slrealtime.internal.ApplicationTree.isTreeNodeSignal(this.Tree.SelectedNodes)))
            this.EditButton.Enable='on';
        else
            this.EditButton.Enable='off';
        end
    end
end
