function overrideAngleTickLabelVis(p,st)




    if strcmpi(st,'default')
        st=internal.LogicalToOnOff(p.AngleTickLabelVisible);
    end





    S=p.pAngleLabelCoords;
    vis=S.labelVis;
    if strcmpi(st,'off')
        set(p.hAngleText,'Visible',st);
    else
        h=p.hAngleText;
        for i=1:numel(h)
            h(i).Visible=vis{i};
        end
    end
