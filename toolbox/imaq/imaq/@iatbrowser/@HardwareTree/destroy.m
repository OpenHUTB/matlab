function destroy(this,destroyJava)












    this.rootNode.destroy();
    this.rootNode=[];

    toolTipManager=javaMethodEDT('sharedInstance','javax.swing.ToolTipManager');
    javaMethodEDT('unregisterComponent',toolTipManager,java(this.javaTreePeer));

    this.javaTreePeer=[];

    if destroyJava
        javaMethodEDT('destroy',java(this.javaPeer));
    end

    this.javaPeer=[];

    this.treeNodeSelectedListener=[];
    this.exportHWConfigListener=[];
    this.exportSelectedHWConfigListener=[];
    this.saveConfigListener=[];
    this.openConfigListener=[];
    this.preferencesListener=[];
    this.exportMFileListener=[];
    this.formatNodeAddedListener=[];

    delete(this);