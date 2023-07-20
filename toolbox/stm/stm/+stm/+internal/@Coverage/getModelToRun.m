

function modelToRun=getModelToRun(this)
    if~isempty(this.harnessName)
        modelToRun=this.harnessName;
    else
        modelToRun=this.modelName;
    end
end