function treeSelectionChanged(this)





    if isempty(this.Tree.SelectedNodes)
        this.AddButton.Enable='off';
    else
        if all(arrayfun(@(x)isempty(x)||isempty(x.NodeData)||isfield(x.NodeData,'path'),this.Tree.SelectedNodes))
            this.AddButton.Enable='off';
        else
            this.AddButton.Enable='on';
        end
    end
    this.updateEditButtonEnable();
end