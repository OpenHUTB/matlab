function exploreAction(this)






    if isLibrary(this)
        r=RptgenML.Root;
        treeNode=r.getCurrentTreeNode;
        if isempty(treeNode)||~isa(treeNode,'rptgen.DAObject')


            treeNode=RptgenML.StylesheetRoot;
        end
        if canAcceptDrop(treeNode,this)
            acceptDrop(treeNode,this);
        end
    end
