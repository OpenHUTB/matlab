function prepareModelForInit(this)




    if this.selfCompiled
        storeDirty=rtwprivate('dirty_restore',this.ModelName);
        if~isempty(this.Model)
            this.BlockReduction=this.Model.BlockReduction;
            this.ConditionallyExecuteInputs=this.Model.ConditionallyExecuteInputs;
            this.Model.BlockReductionOpt='off';
            this.Model.ConditionallyExecuteInputs='off';
        end

        rtwprivate('dirty_restore',this.ModelName,storeDirty);


        this.getTopPortBlockHandles;

    end
end
