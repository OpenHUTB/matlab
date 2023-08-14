function legendPos=getLegendPositionStr(entryValue)
    switch entryValue
    case SdiVisual.LegendPosition.RIGHT
        legendPos='OutsideRight';
    case SdiVisual.LegendPosition.INSIDE_TOP
        legendPos='InsideLeft';
    case SdiVisual.LegendPosition.INSIDE_RIGHT
        legendPos='InsideRight';
    case SdiVisual.LegendPosition.LEGEND_HIDE
        legendPos='None';
    otherwise
        legendPos='TopLeft';
    end
end