function refreshPortEditor(blockID)
    config=[];
    config.BlockId=blockID;
    mainApp=Simulink.playback.mainApp.getController(config);
    if~isempty(mainApp)

        mainApp.updatePortEditor;
    end
end