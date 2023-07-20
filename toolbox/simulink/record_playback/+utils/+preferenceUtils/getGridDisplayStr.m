function grid=getGridDisplayStr(entryValue)
    switch entryValue
    case SdiVisual.GridDisplay.GRID_HIDE
        grid='None';
    case SdiVisual.GridDisplay.HORIZONTAL_ONLY
        grid='Horizontal';
    case SdiVisual.GridDisplay.VERTICAL_ONLY
        grid='Vertical';
    otherwise
        grid='All';
    end
end