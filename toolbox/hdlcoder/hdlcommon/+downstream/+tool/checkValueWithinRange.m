function checkValueWithinRange(dataValue,hObject,dataName)




    if(hObject.isBoolean)

        if(dataValue~=0&&dataValue~=1)
            error(message('hdlcommon:workflow:InvalidInterfaceValueBoolean',dataName));
        end
        return;
    end

    if(isreal(dataValue))
        [minValue,maxValue]=downstream.tool.getMinMaxValueRange(hObject);


        if~isvector(dataValue)||length(dataValue)~=hObject.Dimension
            error(message('hdlcommon:workflow:InvalidInterfaceValueDimension',dataName,hObject.Dimension));
        end


        maxInit=cast(maxValue,'like',dataValue);
        minInit=cast(minValue,'like',dataValue);


        if(any(dataValue>maxInit)||any(dataValue<minInit))
            error(message('hdlcommon:workflow:InvalidInterfaceValueRange',dataName,num2str(minInit),num2str(maxInit)));
        end
    else
        error(message('hdlcommon:workflow:InvalidInterfaceValue',dataName));
    end

end