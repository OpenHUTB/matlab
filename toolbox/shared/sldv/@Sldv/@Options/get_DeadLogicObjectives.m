function prop=get_DeadLogicObjectives(this,prop)




    if~this.checkslavtcchandle

        if isfield(this.PrivateData,'DeadLogicObjectives')
            prop=this.PrivateData.DeadLogicObjectives;
        end
    else
        prop=get_param(this.activeCS,[this.extproductTag,'DeadLogicObjectives']);
    end