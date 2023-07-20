function dataType=makeStringType(appendName)




    dataType='RGParsedString';

    customString=findtype(dataType);
    if isempty(customString)
        customString=schema.UserType(dataType,'String',@checkRgMlString);
    end


    function ok=checkRgMlString(inValue)

        ok=logical(1);
