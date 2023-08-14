function modelEntry=newModelEntry




    modelEntry.model=[];
    modelEntry.modelData.registered=false;
    modelEntry.modelData.examining=false;
    modelEntry.modelData.preswitchCC=[];
    modelEntry.modelData.productsUsed={};
    modelEntry.modelData.modelTopologyChecksum=[];
    modelEntry.modelData.isModelPreRtm=false;
    modelEntry.modelData.modelParameterChecksum=[];
    modelEntry.blockList=initializeBlockList;

    modelEntry.modelOperation=initializeModelOperation;



