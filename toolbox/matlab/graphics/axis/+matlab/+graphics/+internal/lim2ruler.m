function result=lim2ruler(lim,ruler)




    if isa(ruler,'matlab.graphics.axis.decorator.CategoricalRuler')
        result=ruler.makeNonNumericLimits(lim);
    elseif isa(ruler,'matlab.graphics.axis.decorator.NumericRuler')
        result=lim;
    else
        result=ruler.makeNonNumeric(lim);
    end

