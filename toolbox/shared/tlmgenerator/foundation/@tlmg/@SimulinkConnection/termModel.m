function termModel(this)




    if~isempty(this.Model)


        if this.isModelCompiled
            try
                term(this.Model);
            catch me %#ok<NASGU>


            end
        end


        this.Model.BlockReductionOpt=this.BlockReductionOpt;
        this.Model.ConditionallyExecuteInputs=this.ConditionallyExecuteInputs;
        this.Model.Dirty=this.DirtyState;
    end
