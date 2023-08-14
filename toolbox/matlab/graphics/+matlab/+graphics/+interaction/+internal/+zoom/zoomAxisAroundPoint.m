function new_limits=zoomAxisAroundPoint(orig_limits,pt,zoom_factor)

    new_limits(1)=pt-1/zoom_factor*(pt-orig_limits(1));
    new_limits(2)=pt+1/zoom_factor*(orig_limits(2)-pt);