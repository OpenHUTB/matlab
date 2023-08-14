function setBlockCheckedModelOperation(this,block,opName)









    mdl=getBlockModel(block);

    this.modelRegistry.setBlockHasCheckedModelOperation(mdl,opName,block);


