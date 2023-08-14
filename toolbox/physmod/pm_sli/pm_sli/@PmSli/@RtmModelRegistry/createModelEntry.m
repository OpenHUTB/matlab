function idx=createModelEntry(this,mdl)






    idx=this.findModelEntry(mdl);

    if isempty(idx)

        this.collectGarbage;

        modelEntry=newModelEntry;
        modelEntry.model=mdl;

        this.modelInfo(end+1)=modelEntry;
        idx=length(this.modelInfo);

    end





