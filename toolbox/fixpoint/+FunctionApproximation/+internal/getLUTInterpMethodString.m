function interpMethod=getLUTInterpMethodString(interpString)





    if isa(interpString,'FunctionApproximation.InterpolationMethod')
        interpString=char(interpString);
    end
    interpMethod=lower(interpString);
    switch interpMethod
    case 'previous'
        interpMethod='flat';
    case 'linear'
        interpMethod='linear point-slope';
    case 'makima'
        interpMethod='akima spline';
    case 'spline'
        interpMethod='cubic spline';
    end
end
