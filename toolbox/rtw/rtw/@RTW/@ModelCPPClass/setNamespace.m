function setNamespace(hSrc,nsName)










    if nargin>1
        nsName=convertStringsToChars(nsName);
    end

    hSrc.ClassNamespace=nsName;

