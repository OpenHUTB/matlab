function prop=set_DeadLogicObjectives(this,prop)




    if~this.checkslavtcchandle

        if isfield(this.PrivateData,'DeadLogicObjectives')
            this.PrivateData.DeadLogicObjectives=prop;
        end
    else

        if isa(this.activeCS,'Simulink.ConfigSetRef')
            configset.reference.overrideParameter(this.modelH,[this.extproductTag,'DeadLogicObjectives'],prop);
        else
            set_param(this.activeCS,[this.extproductTag,'DeadLogicObjectives'],prop);
        end
    end
