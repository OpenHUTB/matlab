function restoreParams(this)

    if~isempty(this.Model)
        if~this.isModelCompiled&&this.selfCompiled

            storeDirty=rtwprivate('dirty_restore',this.ModelName);
            this.Model.BlockReduction=this.BlockReduction;
            this.Model.ConditionallyExecuteInputs=this.ConditionallyExecuteInputs;
            rtwprivate('dirty_restore',this.ModelName,storeDirty);
            this.selfCompiled=false;
        end
    end
end