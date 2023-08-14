function out=isIntDatatype(datatype)

    if strcmp(datatype,'int8')||strcmp(datatype,'uint8')||...
        strcmp(datatype,'int16')||strcmp(datatype,'uint16')||...
        strcmp(datatype,'int32')||strcmp(datatype,'uint32')

        out=true;
    else
        out=false;
    end
end
