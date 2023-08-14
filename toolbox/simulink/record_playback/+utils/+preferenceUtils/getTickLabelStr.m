function tickLabel=getTickLabelStr(entryValue)
    switch entryValue
    case SdiVisual.TickLabelsDisplay.ALL
        tickLabel='All';
    case SdiVisual.TickLabelsDisplay.T_AXIS
        tickLabel='Timeaxis';
    case SdiVisual.TickLabelsDisplay.Y_AXIS
        tickLabel='YAxis';
    otherwise
        tickLabel='None';
    end
end