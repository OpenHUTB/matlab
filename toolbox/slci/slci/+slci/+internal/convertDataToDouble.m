function value=convertDataToDouble(data)




    if Simulink.data.isSupportedEnumObject(data)
        value=slci.internal.getEnumValue(data);
    else

        value=double(data);
    end
end
