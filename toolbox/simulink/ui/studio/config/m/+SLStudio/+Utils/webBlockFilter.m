function state=webBlockFilter(cbinfo)
    state='Enabled';
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidLegacyWebBlock(target)
        if cbinfo.isContextMenu()
            state='Hidden';
        else
            state='Disabled';
        end
    end
    if SLStudio.Utils.objectIsValidCoreWebBlock(target)
        if cbinfo.isContextMenu()
            state='Hidden';
        else
            state='Disabled';
        end
    end
end
