function success=storeModelSnapshot(this,mdl)






    success=true;

    actualTopologyChecksum=this.computeModelTopologyChecksum(mdl);
    actualParameterChecksum=this.computeModelParameterChecksum(mdl);
    this.storeCachedModelChecksum(mdl,actualTopologyChecksum,actualParameterChecksum);
    this.storeModelBlocksSnapshot(mdl);

