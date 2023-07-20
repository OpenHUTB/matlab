function state=backgroundColorWebBlockFilter(cbinfo)
    state='Enabled';
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    isProperty=isprop(target,'type');
    if isProperty
        isBackgroundColorSupportedForBlock=strcmpi(target.type,'DisplayBlock')...
        ||strcmpi(target.type,'EditField')...
        ||strcmpi(target.type,'PushButtonBlock');
    else
        isBackgroundColorSupportedForBlock=false;
    end
    if SLStudio.Utils.objectIsValidLegacyWebBlock(target)
        if cbinfo.isContextMenu()
            if~isBackgroundColorSupportedForBlock
                state='Hidden';
            end
        else
            state='Disabled';
        end
    end
    if SLStudio.Utils.objectIsValidCoreWebBlock(target)
        if cbinfo.isContextMenu()
            if~isBackgroundColorSupportedForBlock
                state='Hidden';
            end
        else
            state='Disabled';
        end
    end
end
