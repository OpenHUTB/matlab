function[modelData]=getModelData(this,mdl)




    idx=this.findModelEntry(mdl);

    if~isempty(idx)

        modelDataEntry=this.modelInfo(idx).modelData;

    else

        modelEntry=newModelEntry;
        modelDataEntry=modelEntry.modelData;

    end

    modelData.isRegistered=modelDataEntry.registered;
    modelData.isBeingExamined=modelDataEntry.examining;
    modelData.modelTopologyChecksum=modelDataEntry.modelTopologyChecksum;
    modelData.isModelPreRtm=modelDataEntry.isModelPreRtm;
    modelData.modelParameterChecksum=modelDataEntry.modelParameterChecksum;



