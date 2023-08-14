

function initHarnessCoverageSettings(this)
    [ownerType,ownerFullPath]=stm.internal.Coverage.initHarnessCovSettingsHelper(this.modelName,this.harnessName);
    this.ownerType=ownerType;
    this.ownerFullPath=ownerFullPath;
end