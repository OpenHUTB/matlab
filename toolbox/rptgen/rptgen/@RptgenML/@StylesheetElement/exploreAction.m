function exploreAction(this)






    if isLibrary(this)
        currNode=getCurrentTreeNode(RptgenML.Root);

        if~isa(currNode,'rptgen.DAObject')

        elseif canAcceptDrop(currNode,this)
            acceptDrop(currNode,this);
        end
    end
