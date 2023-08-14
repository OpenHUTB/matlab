function updateAngleTickLabelColor(p)


    switch p.ArcTickLabelColorMode
    case{'grid','auto'}
        p.pAngleTickLabelColor=...
        internal.ColorConversion.getRGBFromColor(p.GridForegroundColor);
    case 'contrast'


        bgcolor=getBackgroundColorOfAxes(p);
        if~isempty(bgcolor)
            p.pAngleTickLabelColor=...
            internal.ColorConversion.getBWContrast(bgcolor);
        end
    end
