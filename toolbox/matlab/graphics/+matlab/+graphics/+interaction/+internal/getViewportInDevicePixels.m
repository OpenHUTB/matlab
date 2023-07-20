function vp=getViewportInDevicePixels(fig,container)



    vp=nan(1,4);
    if~isempty(container)

        c=container.getCanvas;
        deviceVP=double(c.Viewport);

        vp=hgconvertunits(fig,deviceVP,'devicepixels','pixels',fig);
    end
