function revertSessionToDefaults(this)







    this.BindingTable.Data={};
    this.BindingData={};
    this.refreshStyles();


    this.OptionsToolstripItem.Value=this.OptionsToolstripItemDefaultValue;
    this.OptionsMenuItem.Value=this.OptionsMenuItemDefaultValue;
    this.OptionsStatusBarItem.Value=this.OptionsStatusBarItemDefaultValue;
    this.OptionsTETMonitorItem.Value=this.OptionsTETMonitorItemDefaultValue;
    this.OptionsInstrumentedSignalsItem.Value=this.OptionsInstrumentedSignalsItemDefaultValue;
    this.OptionsDashboardItem.Value=this.OptionsDashboardItemDefaultValue;
    this.OptionsUseGridItem.Value=this.OptionsUseGridItemDefaultValue;
    this.OptionsCallbackItem.Value=this.OptionsCallbackItemDefaultValue;
    this.TreeConfigureSignals.Value=this.TreeConfigureSignalsDefaultValue;
    this.TreeConfigureParameters.Value=this.TreeConfigureParametersDefaultValue;
    this.SearchEditField.Value='';


    this.destoryAllPropsControls();
    this.createAllPropsControls();


    this.hideAllPropertyPanels();

    this.syncUI();
    this.updateEditButtonEnable();
end

