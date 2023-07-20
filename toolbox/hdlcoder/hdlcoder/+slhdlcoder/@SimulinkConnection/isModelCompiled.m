function compiled=isModelCompiled(this)






    compiled=false;
    if~isempty(this.Model)
        compiled=strcmp(this.Model.SimulationStatus,'paused');
    end
