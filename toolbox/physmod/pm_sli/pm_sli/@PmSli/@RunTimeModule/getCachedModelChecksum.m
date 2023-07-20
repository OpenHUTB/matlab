function[topologyChecksum,parameterChecksum]=getCachedModelChecksum(this,mdl)






    modelData=this.modelRegistry.getModelData(mdl);

    topologyChecksum=modelData.modelTopologyChecksum;
    parameterChecksum=modelData.modelParameterChecksum;



