function overrideResistanceTickLabelVis(p,st)




    if strcmpi(st,'default')
        st=internal.LogicalToOnOff(p.CircleTickLabelVisible);
    end

    set(p.hResistanceText,'Visible',st);
