function mode=getUpdateModeStr(entryValue)
    switch entryValue
    case SdiVisual.UpdateMode.WRAP
        mode='Wrap';
    otherwise
        mode='Scroll';
    end
end