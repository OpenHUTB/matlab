function updateResistanceTickLabelColor(p)


    switch p.CircleTickLabelColorMode
    case{'grid','auto'}
        p.pCircleTickLabelColor=...
        internal.ColorConversion.getRGBFromColor(p.GridForegroundColor);
    case 'contrast'
        p.pCircleTickLabelColor=...
        internal.ColorConversion.getBWContrast(p.GridBackgroundColor);




    end
