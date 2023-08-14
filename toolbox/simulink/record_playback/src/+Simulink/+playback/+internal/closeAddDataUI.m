function closeAddDataUI(blockID)
    config=[];
    config.BlockId=blockID;
    mainApp=Simulink.playback.mainApp.getController(config);
    if(~isempty(mainApp))

        mainApp.AddDataUi.close();
    end
end