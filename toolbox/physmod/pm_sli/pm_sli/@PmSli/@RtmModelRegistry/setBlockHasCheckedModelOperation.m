function setBlockHasCheckedModelOperation(this,mdl,opName,block)






    [opData,mdlIdx]=this.getModelOperationData(mdl);
    opData.opName=opName;
    opData.blocksPerformingOperation=block;

    this.modelInfo(mdlIdx).modelOperation=opData;



