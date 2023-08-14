function overrideAngleTickLabelVis(p,st)




    if strcmpi(st,'default')
        st=internal.LogicalToOnOff(p.ArcTickLabelVisible);
    end
    set(p.hAngleText,'Visible',st);

