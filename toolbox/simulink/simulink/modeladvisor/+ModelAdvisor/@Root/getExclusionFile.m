function fileName=getExclusionFile(this,system)




    fileName='';
    if~isempty(this.modelToExclusion)
        if isKey(this.modelToExclusion,system)
            fileName=this.modelToExclusion(system);
        end
    end
