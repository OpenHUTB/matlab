function prop=get_ModelCoverageObjectives(this,prop)




    if~this.checkslavtcchandle
        if isfield(this.PrivateData,'ModelCoverageObjectives')
            prop=this.PrivateData.ModelCoverageObjectives;
        end
    else
        prop=get_param(this.activeCS,[this.extproductTag,'ModelCoverageObjectives']);
    end
