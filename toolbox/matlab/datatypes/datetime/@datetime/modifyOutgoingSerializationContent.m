function modifyOutgoingSerializationContent(sObj,dt)








    sObj.setSerializationDimensions(size(dt));


    sObj.addPerArrayNameValue("TimeZone",dt.tz);
    sObj.remove("tz");


    if isequal(dt.fmt,'')
        sObj.addPerArrayNameValue("Format",dt.getDisplayFormat());
    else
        sObj.addPerArrayNameValue("Format",dt.fmt);
    end
    sObj.remove("fmt");


    if isreal(dt.data)
        sObj.rename("data","TimeStamp");
    else
        sObj.addNameValue("TimeStamp",real(dt.data));
        sObj.addNameValue("LowOrderTimeStamp",imag(dt.data));
        sObj.remove("data");
    end
end
