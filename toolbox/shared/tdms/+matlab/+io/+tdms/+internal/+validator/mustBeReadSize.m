function mustBeReadSize(value)



    try
        if isnumeric(value)
            mustBePositive(value)
            mustBeInteger(value)
        else
            value=lower(value);
            mustBeMember(value,"file")
        end
    catch ME
        eid="tdms:TDMS:InvalidReadSize";
        error(message(eid));
    end
end