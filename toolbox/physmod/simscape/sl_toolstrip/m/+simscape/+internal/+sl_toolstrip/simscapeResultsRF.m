function simscapeResultsRF(cbinfo,action)



    modelHandle=cbinfo.studio.App.blockDiagramHandle;
    action.enabled=false;
    [log,~]=simscape.logging.sli.internal.getModelLog(modelHandle);
    if~isempty(log)
        action.enabled=true;
    end

end
