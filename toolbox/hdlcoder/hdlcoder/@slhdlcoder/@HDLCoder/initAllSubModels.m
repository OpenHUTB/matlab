function initAllSubModels(this)







    for mdlIdx=numel(this.AllModels)-1:-1:1
        this.mdlIdx=mdlIdx;
        this.AllModels(mdlIdx).slFrontEnd.SimulinkConnection.initModel;
    end
end
