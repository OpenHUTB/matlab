function destroy(this,destroyJava)












    this.prevPanel.destroy(destroyJava);
    this.prevPanel=[];

    this.startAcquisitionBtnListener=[];
    this.widgetListeners=[];
    this.treeNodeListeners=[];
    this.acquisitionParameterListeners=[];

    if strcmp(class(this.errorFcnDoneTimer),'timer')&&isvalid(this.errorFcnDoneTimer)
        stop(this.errorFcnDoneTimer);
        delete(this.errorFcnDoneTimer);
    end

    if strcmp(class(this.stopFcnDoneTimer),'timer')&&isvalid(this.stopFcnDoneTimer)
        stop(this.stopFcnDoneTimer);
        delete(this.stopFcnDoneTimer);
    end

    delete(this);