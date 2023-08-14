function needIt=blockIndicatesNeedForModelOperation(this,mdl,block)












    opData=this.getModelOperationData(mdl);

    needIt=isempty(opData.blocksPerformingOperation)...
    ||...
    (block==opData.blocksPerformingOperation);





