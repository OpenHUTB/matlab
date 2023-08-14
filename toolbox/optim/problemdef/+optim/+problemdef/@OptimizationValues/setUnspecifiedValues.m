function thisValue=setUnspecifiedValues(obj,p,problemProperty,thisQuantityName)









    thisProperty=p.(problemProperty);
    if isstruct(thisProperty)&&~isempty(thisProperty)
        thisQuantity=p.(problemProperty).(thisQuantityName);
    else
        thisQuantity=p.(thisQuantityName);
    end


    if isempty(thisQuantity)||isscalar(thisQuantity)||isvector(thisQuantity)
        thisValue=nan(numel(thisQuantity),obj.NumValues);
    else
        szNan=[size(thisQuantity),obj.NumValues];
        thisValue=nan(szNan);
    end

end
