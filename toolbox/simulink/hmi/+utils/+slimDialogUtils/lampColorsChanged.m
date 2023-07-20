

function lampColorsChanged(dlg,obj,tag)

    [values,colors,success,msg]=utils.validateLampStates(obj);
    defaultColor=obj.DefaultColor;

    if success
        hBlk=get(obj.getBlock(),'Handle');
        set_param(hBlk,'States',{values,colors});
        set_param(hBlk,'DefaultColor',defaultColor);
        dlg.clearWidgetWithError(tag);
        dlg.clearWidgetDirtyFlag(tag);
    else
        dlg.setWidgetWithError(tag,...
        DAStudio.UI.Util.Error(tag,'Error',msg,[255,0,0,100]));
    end
end