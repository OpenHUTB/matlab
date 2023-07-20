function modifyIncomingSerializationContent(sObj)







    data=getAndValidate_data(sObj);
    tz=getAndValidate_tz(sObj);
    fmt=getAndValidate_fmt(sObj,tz);




    sObj.addNameValue("data",data);
    sObj.addNameValue("fmt",fmt);
    sObj.addNameValue("tz",tz);
end

function data=getAndValidate_data(sObj)
    if sObj.hasNameValue("TimeStamp")
        TimeStamp=sObj.getValue("TimeStamp");
        sObj.remove("TimeStamp");

        serialized_sz=sObj.getSerializationDimensions;
        isValidTimeStamp=isa(TimeStamp,'double')&&isequal(size(TimeStamp),serialized_sz);
        if~isValidTimeStamp
            throwAsCaller(MException(message("MATLAB:datetime:serialization:InvalidIncoming","TimeStamp")));
        end

        if sObj.hasNameValue("LowOrderTimeStamp")
            LowOrderTimeStamp=sObj.getValue("LowOrderTimeStamp");
            sObj.remove("LowOrderTimeStamp");



            LowOrderTimeStamp(~isfinite(TimeStamp))=0;


            isValidLowOrderTimeStamp=isa(LowOrderTimeStamp,'double')&&...
            isequal(size(LowOrderTimeStamp),serialized_sz)&&...
            isValidLowOrderBound(TimeStamp,LowOrderTimeStamp);

            if isValidLowOrderTimeStamp



                data=TimeStamp+1i*LowOrderTimeStamp;
            else
                throwAsCaller(MException(message("MATLAB:datetime:serialization:InvalidIncoming","LowOrderTimeStamp")));
            end
        else
            data=TimeStamp;
        end
    else
        throwAsCaller(MException(message("MATLAB:datetime:serialization:MissingIncoming","TimeStamp")));
    end
end

function tz=getAndValidate_tz(sObj)
    if sObj.hasPerArrayNameValue("TimeZone")
        tz=sObj.getPerArrayValue("TimeZone");
        sObj.removePerArrayNameValue("TimeZone");

        try
            verifyTimeZone(tz,false);
        catch
            throwAsCaller(MException(message("MATLAB:datetime:serialization:InvalidIncoming","TimeZone")));
        end
    else
        throwAsCaller(MException(message("MATLAB:datetime:serialization:MissingIncoming","TimeZone")));
    end
end

function fmt=getAndValidate_fmt(sObj,tz)
    if sObj.hasPerArrayNameValue("Format")
        fmt=sObj.getPerArrayValue("Format");
        sObj.removePerArrayNameValue("Format");

        try
            fmt=verifyFormat(fmt,tz);
        catch
            throwAsCaller(MException(message("MATLAB:datetime:serialization:InvalidIncoming","Format")));
        end
    else
        throwAsCaller(MException(message("MATLAB:datetime:serialization:MissingIncoming","Format")));
    end
end

function tf=isValidLowOrderBound(TimeStamp,LowOrderTimeStamp)
    isFiniteTimeStamp=isfinite(TimeStamp);
    tf=all(abs(LowOrderTimeStamp(isFiniteTimeStamp))<=eps(TimeStamp(isFiniteTimeStamp))/2);
end
