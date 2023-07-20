function setModelRtmData(this,mdl,modelTopologyChecksum,modelParameterChecksum,productList)




    idx=this.createModelEntry(mdl);

    this.modelInfo(idx).modelData.modelTopologyChecksum=modelTopologyChecksum;
    this.modelInfo(idx).modelData.modelParameterChecksum=modelParameterChecksum;

    if nargin>=5
        this.setProductsUsed(mdl,productList);
        if isempty(productList)||~iscell(productList)
            this.modelInfo(idx).modelData.isModelPreRtm=true;
        end
    end




