function listenToSelectionChange(this)

    modelName=this.modelName;
    blockH=get_param(modelName,'Handle');

    parentObj=get_param(blockH,'Object');
    L(1)=Simulink.listener(parentObj,'SelectionChangeEvent',...
    @(bd,evt)onSelectionChange(this,evt));
    this.listeners=L;
end


