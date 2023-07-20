function[minValue,maxValue]=getMinMaxValueRange(hObject)





    if(hObject.isSingle)
        maxValue=realmax('single');
        minValue=-maxValue;
    elseif(hObject.isDouble)
        maxValue=realmax('double');
        minValue=-maxValue;
    elseif(hObject.isHalf)
        maxValue=realmax('half');
        minValue=-maxValue;
    else
        maxValue=realmax(fi([],hObject.Signed,hObject.WordLength,-hObject.FractionLength));
        if hObject.Signed
            minValue=-maxValue;
        else
            minValue=0;
        end
    end

end