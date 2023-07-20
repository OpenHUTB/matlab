function setSpectrumSettingMenus(this,val)




    val=uiservices.logicalToOnOff(val);
    handles=this.Handles;
    if isfield(handles,'SpectrumSettingsMenu')
        set(handles.SpectrumSettingsMenu,'Enable',val);
    end
    if isfield(handles,'SpectrumSettingsButton')
        set(handles.SpectrumSettingsButton,'Enable',val);
    end
end
