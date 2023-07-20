function populateNodeAndChildren(this,node)







    if this.TreeProgressDlg.CancelRequested
        return;
    end

    if isa(node,'matlab.ui.container.TreeNode')
        if~isempty(node.Children)

            this.Tree.NodeExpandedFcn(this.Tree,struct('Node',node));
        else

            if this.TreeTotalLeafNodes~=-1
                this.TreeNumLeafNodes=this.TreeNumLeafNodes+1;
                this.TreeProgressDlg.Value=min([this.TreeNumLeafNodes/this.TreeTotalLeafNodes,1]);
            end
        end
    end

    for i=1:numel(node.Children)
        this.populateNodeAndChildren(node.Children(i));
    end
end
