function compiled=isModelCompiled(this)



















    compiled=false;
    if~isempty(this.Model)
        simStatus=this.Model.SimulationStatus;
        if(strcmpi(simStatus,'paused')||strcmpi(simStatus,'initializing')||...
            strcmpi(simStatus,'running'))
            compiled=true;
        end
    end
