function opData=clearModelOperationData(this,mdl)




    [opData,mdlIdx]=this.getModelOperationData(mdl);
    opData=initializeModelOperation;
    this.modelInfo(mdlIdx).modelOperation=opData;


