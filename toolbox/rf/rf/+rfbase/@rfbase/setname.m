function setname(h,name)






    if nargin>1
        name=convertStringsToChars(name);
    end

    set(h,'Name',name);