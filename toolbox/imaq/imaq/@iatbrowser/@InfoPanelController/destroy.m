function destroy(this,destroyJava)












    if destroyJava
        javaMethodEDT('destroy',java(this.javaPeer));
    end

    this.javaPeer=[];

    this.treeNodeListeners=[];
    delete(this);