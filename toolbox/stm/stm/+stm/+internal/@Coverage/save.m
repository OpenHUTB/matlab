



function coverageResults=save(this,runInfo)
    coverageResults=stm.internal.Coverage.saveHelper(this.modelName,this.harnessName,runInfo);
end
