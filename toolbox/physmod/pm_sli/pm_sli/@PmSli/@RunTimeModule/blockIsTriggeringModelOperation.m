function doTrigger=blockIsTriggeringModelOperation(this,block)






    mdl=getBlockModel(block);
    doTrigger=this.modelRegistry.blockIndicatesNeedForModelOperation(mdl,block);




