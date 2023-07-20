function overrideMagnitudeTickLabelVis(p,st)




    if strcmpi(st,'default')
        st=internal.LogicalToOnOff(p.MagnitudeTickLabelVisible);
    end
    set([p.hMagText;p.hMagScale],'Visible',st);


    h=p.hMagAxisLocator;
    if~isempty(h)&&ishghandle(h)
        mag_label_is_vis=strcmpi(st,'on');

        if mag_label_is_vis
            not_st='off';
        else
            not_st='on';
        end
        h.Visible=not_st;

        if~mag_label_is_vis

            hm=p.hMagRegionRect;
            if~isempty(hm)&&ishghandle(hm)
                hm.Visible='off';
            end
        end
    end
