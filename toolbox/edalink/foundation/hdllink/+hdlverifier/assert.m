function assert(dutValue,expValue,varName)






    if nargin>2
        varName=convertStringsToChars(varName);
    end

    if~all(dutValue==expValue)
        warning('hdlverifier:assert:mismatch',...
        'Mismatch found for signal "%s".',...
        varName);
    end
end

