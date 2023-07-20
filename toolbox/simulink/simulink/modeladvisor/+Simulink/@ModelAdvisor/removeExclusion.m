function removeExclusion(this)




    this.ExclusionCellArray={};
    for i=1:length(this.CheckCellArray)
        this.CheckCellArray{i}.ExclusionIndex={};
    end
