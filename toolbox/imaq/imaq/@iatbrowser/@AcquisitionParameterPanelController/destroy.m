function destroy(this,destroyJava)












    if~isempty(this.propertyUpdateTimer);
        this.stopPropertyUpdateTimer();
        delete(this.propertyUpdateTimer);
        this.propertyUpdateTimer=[];
    end;

    this.treeNodeListeners=[];
    this.widgetListeners=[];
    this.sourcePropertyListeners=[];

    this.clearCurrentConfigListener=[];

    this.LogFileIndexIncrementProps.destroy();
    this.incrementLogFileIndexListener=[];

    if destroyJava
        javaMethodEDT('destroy',java(this.javaPeer));
    end

    this.javaPeer=[];

    delete(this);