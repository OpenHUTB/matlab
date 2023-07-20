function new_lims=calculatePannedLimits(lims,delta)
    if isempty(delta)||any(isnan(delta(:)))
        new_lims=lims;
        return;
    end

    new_lims(1:2)=panAxis(lims(1:2),delta(1));
    new_lims(3:4)=panAxis(lims(3:4),delta(2));
    new_lims(5:6)=panAxis(lims(5:6),delta(3));


    function newLim=panAxis(oldLim,d)
        newLim=oldLim+diff(oldLim)*d;