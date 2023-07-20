function tickPos=getTickPositionStr(entryValue)
    switch entryValue
    case SdiVisual.TickPosition.INSIDE
        tickPos='Inside';
    case SdiVisual.TickPosition.HIDE
        tickPos='Hide';
    otherwise
        tickPos='Outside';
    end
end