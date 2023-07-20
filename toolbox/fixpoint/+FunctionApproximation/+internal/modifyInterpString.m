function modifiedString=modifyInterpString(interpString)






    if isa(interpString,'FunctionApproximation.InterpolationMethod')
        interpString=char(interpString);
    end
    modifiedString=lower(interpString);
    switch modifiedString
    case 'clip'
        modifiedString='nearest';
    case 'flat'
        modifiedString='previous';
    case 'cubic spline'
        modifiedString='spline';
    case{'linear lagrange','linear point-slope'}
        modifiedString='linear';
    case{'akima spline'}
        modifiedString='makima';
    end
end


