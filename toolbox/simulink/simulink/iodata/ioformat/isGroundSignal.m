function[bool]=isGroundSignal(aVar)









    if nargin>0
        aVar=convertStringsToChars(aVar);
    end

    bool=(isempty(aVar)&&isnumeric(aVar));


end