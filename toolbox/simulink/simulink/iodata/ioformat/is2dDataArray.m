function[bool]=is2dDataArray(aVar)











    if nargin>0
        aVar=convertStringsToChars(aVar);
    end

    bool=false;


    isArray=isDataArray(aVar);


    dims=size(aVar);

    isNByTwo=length(dims)==2&&dims(2)==2;


    if isArray&&isNByTwo
        bool=true;
    end

end