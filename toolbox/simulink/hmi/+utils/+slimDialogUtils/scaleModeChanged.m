


function scaleModeChanged(dlg,dlgSrc)
    scaleMode=simulink.hmi.getModePosition(dlg.getComboBoxText('scaleModeEdit'));

    if isa(dlgSrc,'hmiblockdlg.MultiStateImageBlock')
        coreScaleModeChanged(dlgSrc,scaleMode);
    else
        legacyScaleModeChanged(dlgSrc,scaleMode);
    end


    dlg.enableApplyButton(false,false);


    dlgs=dlgSrc.getOpenDialogs(true);
    for idx=1:length(dlgs)
        if dlgs{idx}~=dlg
            utils.updateScaleMode(dlgs{idx},scaleMode);
        end
    end

    dlg.clearWidgetDirtyFlag('scaleModeEdit');
end


function coreScaleModeChanged(dlgSrc,scaleMode)
    blockHandle=get(dlgSrc.blockObj,'handle');
    set_param(blockHandle,'ScaleMode',scaleMode);
end


function legacyScaleModeChanged(dlgSrc,scaleMode)
    blockHandle=get(dlgSrc.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    widget=utils.getWidget(mdl,dlgSrc.widgetId,dlgSrc.isLibWidget);
    if~isempty(widget)&&widget.ScaleMode~=scaleMode
        widget.ScaleMode=scaleMode;
        set_param(mdl,'Dirty','on');
    end
end
