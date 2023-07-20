function visibility=getVisibilityStr(entryValue)
    switch entryValue
    case SdiVisual.Visibility.SHOW
        visibility='Show';
    otherwise
        visibility='Hide';
    end
end