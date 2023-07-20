function obj=getCurrentTreeNode(this)




    if isa(this.Editor,'DAStudio.Explorer')
        ime=DAStudio.imExplorer(this.Editor);
        obj=ime.getCurrentTreeNode;
    else
        obj=[];
    end

