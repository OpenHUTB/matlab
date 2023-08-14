function refModelClosed(this,refBdNode)









    me=SigLogSelector.getExplorer;
    me.sleep;


    refMdl=refBdNode.getBdRoot;
    this.hBdNode.isClosing=true;



    selNode=SigLogSelector.getSelectedSubsystem;
    if~isempty(selNode)&&...
        (strcmp(selNode.getBdRoot,refMdl)||isequal(selNode,this))
        me.unloadingModelRefNode=this;
        me.imme.selectTreeViewNode(me.getRoot);
    end


    me.imme.collapseTreeNode(this);


    this.childNodes.deleteDataByKey(refMdl);
    refBdNode.unpopulate;
    this.hBdNode=[];
    this.signalsPopulated=false;
    this.fireHierarchyChanged;


    me.wake;

end
