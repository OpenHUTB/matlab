function handleOpenConfig(this,obj,event)%#ok<INUSL,INUSD,INUSD>

    filename=event.JavaEvent;

    this.loadConfigurationFile(filename);
    this.updateFormatNodesDisplay();

end