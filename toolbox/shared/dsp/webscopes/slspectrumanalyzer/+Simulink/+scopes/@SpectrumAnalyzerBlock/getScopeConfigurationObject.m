function scopeConfig=getScopeConfigurationObject(this,blkHandle)




    scopeConfig=get_param(blkHandle,'ScopeConfigurationObject');
    if isempty(scopeConfig)||scopeConfig.BlockHandle~=blkHandle
        scopeConfig=Simulink.scopes.SpectrumAnalyzerBlockConfiguration(blkHandle,this.ClientID);
        set_param(blkHandle,'ScopeConfigurationObject',scopeConfig);
    end