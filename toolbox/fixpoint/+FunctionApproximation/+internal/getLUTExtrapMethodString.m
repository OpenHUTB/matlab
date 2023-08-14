function extrapMethod=getLUTExtrapMethodString(griddedInterpolantExtrapMethod)





    griddedInterpolantExtrapMethod=lower(griddedInterpolantExtrapMethod);
    extrapMethod=griddedInterpolantExtrapMethod;
    switch griddedInterpolantExtrapMethod
    case 'nearest'
        extrapMethod='clip';
    case 'spline'
        extrapMethod='cubic spline';
    case 'makima'
        extrapMethod='akima spline';
    end
end