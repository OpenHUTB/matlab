function onToolsMenuOpening(this,hScope,~)







    if this.SimscapeMode
        return;
    end

    handles=this.Handles;
    if isempty(handles)||~isfield(handles,'SpectralMaskMenu')
        hTools=hScope.Handles.toolsMenu;
        position=length(hTools.Children);


        handles.SpectralMaskMenu=uimenu(hTools,...
        'Tag','uimgr.spctogglemenu_SpectralMask',...
        'Separator','on',...
        'Position',position,...
        'Label',getString(message('dspshared:SpectrumAnalyzer:SpectralMask')),...
        'Callback',uiservices.makeCallback(@toggleSpectralMaskDialog,this));
        this.Handles=handles;
    end
    set(handles.SpectralMaskMenu,'Checked',uiservices.logicalToOnOff(this.SpectralMaskDialogEnabled))

end
